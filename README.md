# wp-development

Entorn de desenvolupament per wordpress 📰 basat en imatges de docker 🐋

## Dependències

- [docker](https://www.docker.com/)
- [docker-compose](https://docs.docker.com/compose/)
- [degit](https://github.com/Rich-Harris/degit)

## Instal·lació

1. `degit codeccoop/wp-development example.com`
2. Edit `docker-compose.yml` and set:
   1. `services[].wp.build.args.CAPWD` your CA password
   2. `services[].wp.build.args.DOMAIN` your example.com
   3. `dns add -g projects example.com`
3. `docker compose build`
4. `docker compose up -d`
5. `./wp-cli 'core download'`
6. `./wp-cli 'core install --url=example.com --title=<Site Title> --admin_user=admin --admin_email=admin@example.com --admin_password=admin --locale=ca_ES'`
7. `docker compose down`
8. `dns disable example.com`

## Desenvolupament

1. `dns enable example.com`
2. `docker compose up -d`
3. Go to example.com on your browser
