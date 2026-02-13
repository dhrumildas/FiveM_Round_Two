FiveM Server Resources Collection
=================================

> 🎓 **Note**: This project was created for the **Rockstar Mod Jam 2026** in association with **Abertay University**.

A comprehensive collection of FiveM resources designed to enhance gameplay, ranging from advanced phone systems and mission interactions to criminal activities.

⚠️ Requirements
---------------

-   **QBCore Framework**: These resources are designed to work with a functioning QBCore server.

-   **t3_lockpick**: This resource (included) is a **required dependency** for other scripts in this package to function correctly. It must be present in your resources folder.

📦 Included Resources
---------------------

### 📱 NPWD Ecosystem (New Phone Who Dis)

A high-fidelity, React-based phone system with custom extensions.

-   **`npwd`**: The core phone resource. A fully functional, web-based phone with apps for Twitter, Match, Marketplace, and more.

-   **`qb-npwd`**: The bridge resource connecting `npwd` to the **QBCore** framework, ensuring player data, inventory, and bank accounts sync correctly.

-   **`fivem-chop-shop`**: A custom extension/app for NPWD that handles mission distribution and tracking through the phone interface.

### 🔓 Illegal Activities & Minigames

Resources designed to facilitate criminal roleplay.

-   **`t3_lockpick`** (Required Dependency): A visual, skill-based lockpicking minigame.

    -   **Features**: HTML/CSS based UI, sound effects (break, click, unlock), and configurable difficulty.

    -   **Usage**: Can be exported to other scripts to trigger the lockpick game before an action (e.g., carjacking, house robbery).

📥 Installation
---------------

1.  **Download** the repository.

2.  **Copy** the folders into your FiveM server's `resources` directory (e.g., `[standalone]` or `[qb]`).

3.  **Database**:

    -   Run `npwd/import.sql` to set up the necessary tables for the phone.

    -   Run `qb-npwd/patch.sql` if required for specific QBCore database adjustments.

4.  **Server Config**: Add the following lines to your `server.cfg`:

    ```
    # NPWD Configuration
    set npwd:framework qbcore

    # Dependencies (Must start before the mission)
    ensure oxmysql         #database
    ensure PolyZone        #zones and areas
    ensure t3_lockpick     #lockpick minigame
    ensure qb-target       #interactions

    # Main App
    ensure qb-npwd
    ensure npwd
    ensure fivem-chop-shop

    ```

⚙️ Configuration
----------------

### NPWD (`npwd/config.json`)

Manage general phone settings, default apps, and permissions.

### Lockpick (`t3_lockpick/config.lua`)

Adjust the difficulty, speed, and pin count for the lockpicking minigame.

⚖️ Credits & Licenses
---------------------

-   **NPWD**: Project Error Team

-   **Lockpick**: T3
