Chop Shop Setup (QBCore)
========================

Requirements
------------

-   **QBCore server**

-   **oxmysql**

Resources Used
--------------

-   **ox_lib** -- UI, skillchecks, progress bars

-   **ps-ui** -- lockpick minigame (stealing cars)

-   **chopshops-v2** -- base chop shop logic

-   **ox_target** *(or qb-target)* -- interactions

* * * * *

Installation
------------

### 1\. Download & place resources

resources/

├─ [standalone]/

│  ├─ ox_lib/

│  └─ ox_target/        (or qb-target)

│

├─ [qb]/

│  ├─ ps-ui/

│  └─ chopshops-v2/


> Folder names **must match** the resource name.

* * * * *

### 2\. server.cfg (order matters)

`ensure qb-core
ensure oxmysql

ensure ox_lib
ensure ps-ui

ensure ox_target      # OR qb-target (not both)
ensure chopshops-v2`

* * * * *

### 3\. First start

1.  Start server once

2.  Let `ox_lib` generate configs

3.  Restart server

* * * * *

Notes
-----

-   **Lockpick** is handled via `ps-ui`

-   **Chopping minigames** use `ox_lib` skill checks

-   No paid assets required

-   Do **not** run qb-target and ox_target together
