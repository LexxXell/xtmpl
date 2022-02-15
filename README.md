***XTMPL***

XTMPL allows you to quickly deploy containers based on docker-compose. You get already configured containers with base code on selected platforms.

Supported platforms:
- Python
- NodeJS
- PostgreSQL
- Redis
- nginx

Various combinations of these platforms are available.

*Usage:*

    sh <path_to>/xtmpl.sh <option> - If not installed
    xtmpl <option> - If installed

*Options:*

    init - Initialize new docker-compose based application.

    --install-xtmpl -  Install xtmpl in system bin. SUPERUSER or SUDO need.

    --reload-template - Reload local template files.

    -dc, --docker-cleanup
        soft -  Soft docker cleanup. Stopped containers, unused images,
                volumes and networks not related to running containers will be deleted.

        hard -  Hard docker cleanup. All containers will be stopped. 
                All containers, volumes and networks will be deleted.

    -h, --help - This help.
