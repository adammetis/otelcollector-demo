$location = (get-location).path
$Key = "${location}\ssh_tunnel\tunnel_rsa"
Icacls $Key /c /t /Inheritance:d
TakeOwn /F $Key
Icacls $Key /c /t /Grant:r ${env:UserName}:F
Icacls $Key /c /t /Remove:g Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users
Icacls $Key

docker build -t otelcollector_ssh ssh_tunnel

docker start otelcollector_ssh

if($LASTEXITCODE -ne 0){
docker run -d `
  --name=otelcollector_ssh `
  -e TZ=Etc/UTC `
  -e "PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhcqS0uL1+ymfVY0auRFIALGGNCHtRwATetPQDrFs3tdPFjcLFl1KWOkJLxawYQ3jgkmUwr3Hn+aeqkwNnoR5suD+icVYOSrjG68vOpqezUMAwV8T4wT8feJAS3x0M6yARXwxl2zCBLfip8/gryqKfR8rCt82HqFSo1GnmwuW6VKp7mqkDEcqpk0k2oSYny1j06n6tbqOdPX2qTc7sYtW53AfdcAw7QTwGeR4kr4/6kDUh2t+tl82OMbgDstZbyLR/6NjvTHVLa5qOj+D174S2KhguVWKuy7kjaElQ9xU0Bhciu19i5sxhwdR1pp1qAxJBcIuIuVtIPLWXLPj653nJ" `
  -p 127.0.0.1:58225:2222 `
  -e USER_NAME=tunnel `
  --restart unless-stopped `
  otelcollector_ssh
}

sleep 5

ssh-keygen -R '[localhost]:58225'
$replacedLocation = $location.replace("\", "/")
(Get-WmiObject win32_process -filter "Name='ssh.exe' AND CommandLine LIKE '%${replacedLocation}/ssh_tunnel/tunnel_rsa tunnel@localhost -p 58225%'").Terminate()
$sshStartBlock = { param([string]$pwd) ssh -i "$pwd/ssh_tunnel/tunnel_rsa" tunnel@localhost -p 58225 -4 -o StrictHostKeyChecking=no -R 5432:127.0.0.1:5432 -L 4318:127.0.0.1:4318 -fN }
start-job -ScriptBlock $sshStartBlock -ArgumentList $replacedLocation

docker start metis-otel-collector
if($LASTEXITCODE -ne 0){
$apiKey = [System.Environment]::GetEnvironmentVariable('METIS_API_KEY');
docker run `
  --name metis-otel-collector `
  -e "METIS_API_KEY=${apiKey}" `
  -e "CONNECTION_STRING=postgresql://postgres:postgres@127.0.0.1:5432/demo?schema=imdb" `
  -e "LOG_LEVEL=debug" `
  --network 'container:otelcollector_ssh' `
  public.ecr.aws/o2c0x5x8/metis-otel-collector:latest
}
