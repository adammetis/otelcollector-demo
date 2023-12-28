ssh-keygen -R '[localhost]:58225'
$location = (get-location).path
$replacedLocation = $location.replace("\", "/")
(Get-WmiObject win32_process -filter "Name='ssh.exe' AND CommandLine LIKE '%${replacedLocation}/ssh_tunnel/tunnel_rsa tunnel@localhost -p 58225%'").Terminate()
docker stop metis-otel-collector -t 1
docker rm --force metis-otel-collector
docker rmi --force public.ecr.aws/o2c0x5x8/metis-otel-collector
docker stop otelcollector_ssh -t 1
docker rm --force otelcollector_ssh
docker rmi --force otelcollector_ssh
docker rmi --force public.ecr.aws/o2c0x5x8/community-images-backup:lscr.io-linuxserver-openssh-server
docker system prune
docker volume prune