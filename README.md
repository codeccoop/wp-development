# wp-development

Entorn de desenvolupament per wordpress 📰 basat en imatges de docker 🐋

## Dependències

- [docker](https://www.docker.com/)
- [docker compose](https://docs.docker.com/compose/)
- [degit](https://github.com/Rich-Harris/degit)

## Installation

1. Descàrrega un nou entorn de desenvolupament amb degit així `degit codeccoop/wp-development wp-example && cd wp-example`.
2. Edita l'arxiu `compose.yml`. Hi ha uns pocs canvis a fer:
   1. `services.wp.build.args` Conté els arguments que controlen el procés de compilat de la imatge de Docker.
      * **DOMAIN**: Configura la instància d'Apache del contenidor a un domini. Fes servir localhost si no utilitzes resolució
        local de DNS.
      * **CAPWD**: Certificate Authority Password. Contrasenya per poder generar els certificats SSL del contenidor. La trobaràs a
        [Vaultwarden](https://oficina.codeccoop.org/vaultwarden).
      * **XDEBUG**: Heredada de l'arxiu `.env`. Pots editar l'arxiu `.env` o sobreescriure el valor a "yes" o "on" per activat
      * XDebug dins el contenidor,.
   2. `services.wp.hostname` Indica el mateix valor que el domini utilitzat als arguments de compilació.
4. Un cop configurat l'arxiu YAML, executem la compilació de la imatge amb `docker compose build`. Dockerfile fa ús de la imatge oficial [`wordpress:latest`](https://hub.docker.com/_/wordpress)
  com a punt de partida.
6. Arribats fins aquí, pots aixecar i tumbar els teus contenidors amb les comandes `docker compose up -d` i `docker compose down`
7. Fes servir l'arxiu executable `wp-cli` per accedir al [wp-cli](https://wp-cli.org/) disponible dins el contenidor. Executa la
   comanda següent per iniciar la instal·lació i configuració inicial de WordPress:
   `./wp-cli 'core install --url=example.coop --title=<Site Title> --admin_user=admin --admin_email=admin@example.coop --admin_password=admin --locale=ca_ES'`
10. Abans de visitar la pàgina, fes servir [dns-cli](https://github.com/codeccoop/hosts-cli) per registrar el teu domini de desenvolupament
    al sistema de resolució de DNS local: `dns add example.coop`
12. Obre el navegador i visita https://example.coop 🚀.
