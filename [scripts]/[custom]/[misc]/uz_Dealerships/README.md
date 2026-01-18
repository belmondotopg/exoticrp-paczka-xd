# Taintless Dealerships by UZ Scripts

**A modern, feature-rich vehicle dealership system for your FiveM server, designed for both ESX, QBCore and QBox frameworks.**

---

## 🛍️ Purchase & Other Scripts

You can purchase this script or explore other high-quality scripts on our official store:

-   **Official Store:** [https://uz-scripts.com](https://uz-scripts.com)

---

## 🛠️ Installation

1.  **Download:** Download the script files.
2.  **Directory:** Place the `uz_Dealerships` folder into your server's `resources` directory.
3.  **Database:** Import the SQL query below into your database to create the necessary table for the financing system.
4.  **Server Config:** Add `ensure uz_Dealerships` to your `server.cfg` file. Make sure it's started *after* your framework (`es_extended` or `qb-core`) and `oxmysql`.

```sql
CREATE TABLE IF NOT EXISTS `uz_dealership_financing` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `owner` varchar(50) NOT NULL DEFAULT '0',
    `plate` varchar(15) DEFAULT NULL,
    `data` longtext DEFAULT NULL,
    `paymentamount` int(11) DEFAULT NULL,
    `paymentsleft` int(11) DEFAULT NULL,
    `financetime` int(11) DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## ⚙️ Configuration

All configuration can be done within the `customize/` and `locales/` directories. For a detailed guide on all available options, please refer to our official documentation.

---

## 📚 Documentation

For complete and detailed information about this script, please visit our official documentation:

📑 **[docs.uz-scripts.com](https://docs.uz-scripts.com/)**

---

## 💬 Support & Community

Are you having trouble? Need help with configuration? Join our community!

-   **Discord:** [Join the UZ Scripts Discord](https://discord.uz-scripts.com/)

Our support team is available on Discord to help you with any issues you might encounter.

---

**Thank you for choosing Taintless Dealerships. We hope you enjoy it! 🚀**
