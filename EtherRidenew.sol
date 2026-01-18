// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Decentralized Ride Sharing
 * Smart contract untuk sistem ojek online berbasis blockchain dengan sistem Escrow.
 */
contract RideSharing {
    
    // Enum untuk menyimpan status perjalanan secara berurutan
    enum Status { Requested, Accepted, Funded, Started, CompletedByDriver, Finalized, Cancelled }

    // Struktur data untuk menyimpan detail pesanan
    struct Ride {
        uint id;
        address passenger;
        address driver;
        string pickup;
        string destination;
        uint fare;
        Status status;
    }

    // Struktur data untuk profil pengemudi
    struct Driver {
        string name;
        string plate;
        string vehicleType; // Menyimpan jenis kendaraan (Mobil/Motor)
        uint rate;          // Tarif per kilometer atau flat
        bool isRegistered;
    }

    // Mapping untuk menyimpan data driver dan rides
    mapping(uint => Ride) public rides;
    mapping(address => Driver) public drivers;
    uint public rideCount = 0;

    // Event untuk log aktivitas di blockchain (Opsional, untuk debugging)
    event RideRequested(uint id, address passenger);
    event RideStatusChanged(uint id, Status status);

    /**
     * Mendaftarkan driver baru ke dalam sistem.
     * @param _name Nama lengkap driver.
     * @param _plate Nomor polisi kendaraan.
     * @param _vehicleType Jenis kendaraan.
     * @param _rate Tarif yang ditawarkan.
     */
    function registerDriver(string memory _name, string memory _plate, string memory _vehicleType, uint _rate) public {
        require(!drivers[msg.sender].isRegistered, "Error: Alamat ini sudah terdaftar sebagai driver.");
        drivers[msg.sender] = Driver(_name, _plate, _vehicleType, _rate, true);
    }

    /**
     * Mengambil data driver berdasarkan address wallet.
     * @return Nama, Plat Nomor, Tipe Kendaraan, dan Tarif.
     */
    function getDriver(address _addr) public view returns (string memory, string memory, string memory, uint) {
        Driver memory d = drivers[_addr];
        return (d.name, d.plate, d.vehicleType, d.rate);
    }

    /**
     * Penumpang membuat pesanan baru.
     * Status awal akan diset menjadi 'Requested'.
     */
    function requestRide(string memory _pickup, string memory _dest, uint _fare) public {
        rideCount++;
        rides[rideCount] = Ride(rideCount, msg.sender, address(0), _pickup, _dest, _fare, Status.Requested);
        emit RideRequested(rideCount, msg.sender);
    }

    /**
     * Driver menerima pesanan yang tersedia.
     * Syarat: Pemsan statusnya harus 'Requested'.
     */
    function acceptRide(uint _id) public {
        require(drivers[msg.sender].isRegistered, "Error: Hanya driver terdaftar yang bisa menerima order.");
        require(rides[_id].status == Status.Requested, "Error: Pesanan tidak tersedia atau sudah diambil.");
        
        rides[_id].driver = msg.sender;
        rides[_id].status = Status.Accepted;
        emit RideStatusChanged(_id, Status.Accepted);
    }

    /**
     * Penumpang menyetor dana ke Smart Contract (Escrow).
     * Dana akan ditahan hingga perjalanan selesai.
     */
    function fundRide(uint _id) public payable {
        require(msg.sender == rides[_id].passenger, "Error: Hanya penumpang asli yang bisa melakukan pembayaran.");
        require(rides[_id].status == Status.Accepted, "Error: Driver belum menerima pesanan ini.");
        require(msg.value == rides[_id].fare, "Error: Jumlah ETH yang dikirim tidak sesuai dengan harga.");

        rides[_id].status = Status.Funded;
        emit RideStatusChanged(_id, Status.Funded);
    }

    /**
     *Driver memulai perjalanan setelah dana masuk (Funded).
     */
    function startRide(uint _id) public {
        require(msg.sender == rides[_id].driver, "Error: Akses ditolak. Anda bukan driver pesanan ini.");
        require(rides[_id].status == Status.Funded, "Error: Penumpang belum melakukan pembayaran (Escrow).");
        
        rides[_id].status = Status.Started;
        emit RideStatusChanged(_id, Status.Started);
    }

    /**
     *Driver menyelesaikan perjalanan (Sampai tujuan).
     */
    function completeRide(uint _id) public {
        require(msg.sender == rides[_id].driver, "Error: Akses ditolak.");
        rides[_id].status = Status.CompletedByDriver;
        emit RideStatusChanged(_id, Status.CompletedByDriver);
    }

    /**
     * Penumpang mengonfirmasi perjalanan selesai.
     * Dana Escrow dicairkan (transfer) ke wallet driver.
     */
    function confirmArrival(uint _id) public {
        require(msg.sender == rides[_id].passenger, "Error: Akses ditolak.");
        require(rides[_id].status == Status.CompletedByDriver, "Error: Driver belum menyelesaikan perjalanan.");

        rides[_id].status = Status.Finalized;
        
        // Transfer dana ke driver menggunakan metode .call untuk keamanan
        (bool success, ) = rides[_id].driver.call{value: rides[_id].fare}("");
        require(success, "Error: Gagal mentransfer dana ke driver.");
        
        emit RideStatusChanged(_id, Status.Finalized);
    }

    /**
     * Membatalkan pesanan jika belum diambil driver.
     */
    function cancelRide(uint _id) public {
        require(msg.sender == rides[_id].passenger, "Error: Akses ditolak.");
        require(rides[_id].status == Status.Requested, "Error: Pesanan sudah berjalan, tidak bisa dibatalkan.");
        
        rides[_id].status = Status.Cancelled;
        emit RideStatusChanged(_id, Status.Cancelled);
    }
}