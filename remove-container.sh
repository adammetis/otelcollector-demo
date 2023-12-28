ssh-keygen -R '[localhost]:58225'
pkill -f "ssh -i $(pwd)/ssh_tunnel/tunnel_rsa tunnel@localhost -p 58225"
docker stop metis-otel-collector -t 1
docker rm --force metis-otel-collector
docker rmi --force 357242092635.dkr.ecr.eu-central-1.amazonaws.com/metis-otel-collector:latest
docker stop otelcollector_ssh -t 1
docker rm --force otelcollector_ssh
docker rmi --force otelcollector_ssh
docker rmi --force public.ecr.aws/o2c0x5x8/community-images-backup:lscr.io-linuxserver-openssh-server
docker system prune
docker volume prune