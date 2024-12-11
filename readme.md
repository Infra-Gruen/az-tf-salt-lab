# SALT Lab

Der terraform Code dieses Repositorys rollt die Ressourcen für einen kleinen Saltstack Testaufbau aus. Die Ressourcen umfassen:
- Netzwerk und Subnetze
- Eine VM mit installierem Salt-Master Paket
- Eine VM mit installiertem Salt-Minion Paket
- Eine weitere, auskommentierte, VM mit dem Salt-Minion Paket, die im Bedarfsfall ebenfalls ausgerollt werden kann
- Ein Bastion-Host für den Zugriff auf die VMs

# Voraussetzungen

### Azure
Es sollte Zugriff auf den Automatisierungshelden Tenant in Azure vorhanden sein. Idealerweise wurde bereits ein ServiceUserPrincipal angelegt und mit den notwendigen Berechtigungen ausgestattet.

### Terraform
Die Inhalte dieses Repositorys müssen lokal verfügbar sein.
Auf dem Gerät, auf dem das Deployment ausgeführt wird, muss terraform installiert sein. Terraform kann unter Windows aus der PowerShell oder aus der WSL-Shell aufgerufen werden.

# Deployment



#### Bei Bedarf: Ausrollen des zweiten Minions
Falls der zweite Minion benötigt wird, muss die Kommentierung des Codes aufgehoben werden. D.h. die '#' müssen vor den Codezeilen entfernt werden.
Der Code für den zweiten Minio beginnt nach dem Kommentar ```###### salt-minion2 #######```

### Initiieren des Deployments
```
terraform init 
```
In der Konsole in das Verzeichnis mit den Inhalten des Repositorys navigieren und den init Befehl ausführen. Dadurch werden die benötigten Provider heruntergeladen.

### Syntaktische Validierung
```
terraform vaildate
```
Durch diesen Befehl wird der Code auf syntaktische Fehler geprüft, jedoch können weiterhin logische o.ä. Fehler enthalten sein.

### Deployment
```
terraform apply
```
Wenn keine Fehler während der Validierung angezeigt wurden, kann der Code angewendet werden. Während der Ausführung werden in der Konsole die Werte für das Admin-Kennwort und das Secret für den Azure Service Principal abgefragt. Diese beiden Werte sollten auf keinen Fall hardcoded im Code enthalten sein!

# Post-Deployment

## Zugriff auf die VMs
Der Zugriff auf die VMs läuft über den Bastion Host im Azure Portal. Bitte beachten: Das Deploy des Bastion Hosts dauert deutlich länger als das Deployment der VMs

## Salt Installation
Im Hintergrund werden via Cloud-Init die Salt-Master bzw. Salt-Minion Pakete installiert. Die Installation läuft üblicherweise noch, wenn die VM bereits verfügbar ist. Sobald der Salt-Master Dienst bzw. der Salt-Minion Dienst gestartet ist, ist die Installation abgeschlossen. Dies kann über den systemctl status des Dienstes geprüft werden

```
systemctl status salt-master
# Oder
systemctl status salt-minion
```
## Salt Post-Deployment
Nach dem Deployment muss der Salt-Key des Minions noch vom Master akzeptiert werden

### Keys anzeigen 

```
sudo salt-key 
```
Der Name des ersten Minions sollte unter "Unaccepted Keys" zu finden sein. Standardmäßig lautet er: "*lab-saltminion.internal.cloudapp.net*"
### Key akzeptieren 
```
sudo salt-key -a lab-saltminion.internal.cloudapp.net 
```


***Viel Spaß beim Experimentieren!***