[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=eineOrganisation_guessingAverage&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=eineOrganisation_guessingAverage)
![CI Maven](https://github.com/eineOrganisation/guessingAverage/actions/workflows/maven.yml/badge.svg)
<br><br><br><br>
# GuessingAvg - Na, heute schon geraten?
Das Spiel GuessingAverage fordert das Glück (und mathematische Verständnis) heraus. 
Ziel ist es den Durchschnitt der gespeicherten Zahlen möglichst genau zu erraten. 
Dabei wird jedoch jeder Guess ebenfalls gespeichert und beeinflusst somit den Durchschnitt.

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

Bild

In der Darstellung werden einige Bestandteile aus Gründen der Übersichtlichkeit nicht angezeigt. Zum Beispiel sind der ELB, die EC2-Intanzen und die Datenbank mit Security-Groups abgesichert. 
Die SG des ELB akzeptiert und leitet nur eingehende HTTP:80 Anfragen an die EC2-Instanzen weiter.
Die SG der EC2-Instanzen erlauben nur eingehenden Traffic von der SG des ELB und SSH:22 von dem Netz der THB. 
Die SG der DB erlaubt nur eingehende Anfragen der SG der EC2-Instanzen. 
Außerdem wurden in der Darstellung die Routing-Tables der einzelnen Subnets weggelassen. <br>
Der nächste Abschnitt wirft einen genaueren Blick auf die Continuous Delivery Pipeline und wie diese mit GitHub und AWS umgesetzt wurde. 