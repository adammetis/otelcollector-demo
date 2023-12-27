ssh-keygen -R '[localhost]:58224'
$location = (get-location).path
$replacedLocation = $location.replace("\", "/")
(Get-WmiObject win32_process -filter "Name='ssh.exe' AND CommandLine LIKE '%${replacedLocation}/ssh_tunnel/tunnel_rsa tunnel@localhost -p 58224%'").Terminate()
docker stop metis-otel-collector -t 1
docker rm --force metis-otel-collector
docker rmi --force 357242092635.dkr.ecr.eu-central-1.amazonaws.com/metis-otel-collector:e1164b922b63b891b8a7761dc44e2233372b6d70
docker stop otelcollector_ssh -t 1
docker rm --force otelcollector_ssh
docker rmi --force otelcollector_ssh
docker rmi --force public.ecr.aws/o2c0x5x8/community-images-backup:lscr.io-linuxserver-openssh-server
docker system prune
docker volume prune