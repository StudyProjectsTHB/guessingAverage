[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=eineOrganisation_guessingAverage&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=eineOrganisation_guessingAverage)
![CI Maven](https://github.com/eineOrganisation/guessingAverage/actions/workflows/maven.yml/badge.svg)
<br><br><br><br>
# GuessingAvg - Na, heute schon geraten?
Das Spiel GuessingAverage fordert das Glück (und mathematische Verständnis) heraus. 
Ziel ist es den Durchschnitt der gespeicherten Zahlen möglichst genau zu erraten. 
Dabei wird jedoch jeder Guess ebenfalls gespeichert und beeinflusst somit den Durchschnitt.

## [Installation](INSTALL.md)


## Dokumentation

### Die Komponenten
![UML-Klassendiagramm der Anwendung](https://github.com/eineOrganisation/guessingAverage/assets/79515919/1b605428-c9e9-48a1-9874-f044bcbefa19)
*UML-Klassendiagramm der Anwendung*

Die Klassen der Anwendung und ihre Struktur innerhalb der Pakete entsprechen dem im Bild gezeigten UML-Diagramm. Die wichtigsten Endpunkte für einen Nutzer stellt der NumberController bereit. Die Methode controlNumber ist dabei für den GET-Request zuständig und gibt das gerenderte HTML-Template zurück. Die addNumber-Methode dagegen reagiert auf den POST-Request eines Nutzers, sobald dieser einen Durchschnitt rät. Der Controller verwendet die GuessingAverageProperties. In diesen ist enthalten, bei wie vielen neuen Einträgen (randomNumberFrequency), in welchem Rahmen eine zufällige Anzahl (minNumber und maxNumber) an neuen NumberEntries mit einem zufälligen Wert in einem gegebenen Bereich (minValue, maxValue) erzeugt werden sollen. Die Daten werden dabei aus der `application.properties` entnommen. Um diese NumberEntries dann wirklich zu erstellen, greift der Controller auf die Methode `createRandomNumberOfRandomEntries` des `NumberEntryServices` zu. Der `NumberEntryServices` wird außerdem vom Controller für die Bereitstellung der Daten im View verwendet. Die Methoden `calculateTotalAverageNumber`, `calculateTotalMedianNumber`, `getTotalMaxNumber` und `getTotalMinNumber` holen sich alle bestehenden NumberEntries aus der Datenbank (über das `NumberRepository`) und lassen sich den entsprechenden Wert vom `NumberEntryCalculationService` zurückgeben. Dieser berechnet die Werte auf Basis einer übergebenen Liste an NumberEntries.
<br><br>
Eine weitere wichtige Komponente der Anwendung ist der `MyApplicationRunner`, der über den `NumberEntryService` eine zufällige Anzahl an NumberEntries mit zufälligem Wert erstellt. Dabei wird ebenfalls die `GuessingAverageProperties` Klasse verwendet, um die wichtigen Parameter aus der `application.properties` auszulesen.

### Die Cloud-Infrastruktur

Mithilfe von Terraform lässt sich eine Cloud-Infrastruktur aufsetzen, welche die guessingAverage-Anwendung hostet. 
Das folgende Bild stellt den Aufbau der Cloud-Infrastruktur dar, welche standardmäßig durch Terraform erstellt wird. <br>
Die farbigen Pfeile stellen hierbei die verschiedenen Kommunikationen dar. 
Grün steht für die Kommunikation des "Standardnutzers" der Anwendung. Der Standardnutzer stellt hierbei eine HTTP Anfrage an den Elastic-Load-Balancer auf Port 80 und die EC2 Instanzen antworten hierauf. 
Die roten Pfeile symbolisieren den Zugriff eines Admins (aus dem Netzwerk der THB) über SSH. 
Die orangenen Pfeile stehen für den Zugriff auf das öffentliche Internet, ausgehend von den EC2 Instanzen. 

![image](https://github.com/eineOrganisation/guessingAverage/assets/82468704/da0db14a-30fc-4548-bdb7-da2b8fefa875)
*Cloud-Infrastruktur der Anwendung*

In der Darstellung werden einige Bestandteile aus Gründen der Übersichtlichkeit nicht angezeigt. Zum Beispiel sind der ELB, die EC2-Intanzen und die Datenbank mit Security-Groups abgesichert. 
Die SG des ELB akzeptiert und leitet nur eingehende HTTP:80 Anfragen an die EC2-Instanzen weiter.
Die SG der EC2-Instanzen erlauben nur eingehenden Traffic von der SG des ELB und SSH:22 von dem Netz der THB. 
Die SG der DB erlaubt nur eingehende Anfragen der SG der EC2-Instanzen. 
Außerdem wurden in der Darstellung die Routing-Tables der einzelnen Subnets weggelassen. <br>
Der nächste Abschnitt wirft einen genaueren Blick auf die Continuous Delivery Pipeline und wie diese mit GitHub und AWS umgesetzt wurde. 

### Der Update-Prozess

![CC_AWS_Terraform_Update](https://github.com/eineOrganisation/guessingAverage/assets/72797311/d4ea062c-18c7-43d6-8375-20d6662bb509)
*Der Update-Prozess grafisch dargestellt*

Bei jedem Push in das `GitHub Repository` wird eine `GitHub Action` gestartet. Diese führt zunächst die `Unit- und Integrationstests` mit `mvn install` durch. Sind diese erfolgreich, wird ein `Docker-Image` erstellt und auf das `Docker-Repository` gepusht. Anschließend sendet GitHub einen Webhook an das `AWS API Gateway`. Dieses leitet die Informationen aus dem Webhook an eine `Lambda-Funktion` weiter, welche die `Referenz-EC2-Instanz` aktualisiert und die neueste Docker-Version herunterlädt. Sobald die Aktualisierung der EC2 Instanz abgeschlossen ist, wird eine `SQS` benachrichtigt. Diese aktiviert eine Lambda-Funktion, die ein `AMI` aus der Referenz-EC2-Instanz erstellt. Danach aktiviert sie ein `Event` für in 2 Minuten für eine weitere Lambda Funktion, die überprüft, ob das AMI bereits fertig erstellt wurde. Ist dies nicht der Fall, wird das Event in 2 Minuten erneut ausgelöst. Ist das AMI fertig erstellt, wird daraus eine neue Version des `Launch Templates` erstellt. Sollte während der Erstellung des AMI ein weiteres Mal auf das GitHub Repository gepusht werden, wird das AMI verworfen und ein neues AMI wird erstellt. Mit dieser wird die `Auto Scaling Group` aktualisiert und ein `Instance Refresh` durchgeführt. Sollte der Instance Refresh fehlschlagen, weil bereits ein Instance Refresh läuft, wird dies in eine weitere SQS geschrieben. Nachdem die Auto Scaling Group ihren Instance Refresh abgeschlossen hat, wird ein Event ausgelöst, das eine Lambda-Funktion auslöst. Diese Lambda-Funktion prüft, ob die SQS gefüllt ist. Sollte dem so sein, gab es während dem Instance Refresh einen erneuten Push auf das GitHub und der Instance Refresh wird neu gestartet. Wenn die SQS leer ist, ist die Aktualisierung der Auto Scaling Group abgeschlossen und die Continous Delivery Pipeline beendet.




