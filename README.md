[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=eineOrganisation_guessingAverage&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=eineOrganisation_guessingAverage)
![CI Maven](https://github.com/eineOrganisation/guessingAverage/actions/workflows/maven.yml/badge.svg)

# Dokumentation

## Die Komponenten
![UML-Klassendiagramm der Anwendung](https://github.com/eineOrganisation/guessingAverage/assets/79515919/1b605428-c9e9-48a1-9874-f044bcbefa19)
*UML-Klassendiagramm der Anwendung*

Die Klassen der Anwendung und ihre Struktur innerhalb der Pakete entsprechen dem im Bild gezeigten UML-Diagramm. Die wichtigsten Endpunkte für einen Nutzer stellt der NumberController bereit. Die Methode controlNumber ist dabei für den GET-Request zuständig und gibt das gerenderte HTML-Template zurück. Die addNumber-Methode dagegen reagiert auf den POST-Request eines Nutzers, sobald dieser einen Durchschnitt rät. Der Controller verwendet die GuessingAverageProperties. In diesen ist enthalten, bei wie vielen neuen Einträgen (randomNumberFrequency), in welchem Rahmen eine zufällige Anzahl (minNumber und maxNumber) an neuen NumberEntries mit einem zufälligen Wert in einem gegebenen Bereich (minValue, maxValue) erzeugt werden sollen. Die Daten werden dabei aus der `application.properties` entnommen. Um diese NumberEntries dann wirklich zu erstellen, greift der Controller auf die Methode `createRandomNumberOfRandomEntries` des `NumberEntryServices` zu. Der `NumberEntryServices` wird außerdem vom Controller für die Bereitstellung der Daten im View verwendet. Die Methoden `calculateTotalAverageNumber`, `calculateTotalMedianNumber`, `getTotalMaxNumber` und `getTotalMinNumber` holen sich alle bestehenden NumberEntries aus der Datenbank (über das `NumberRepository`) und lassen sich den entsprechenden Wert vom `NumberEntryCalculationService` zurückgeben. Dieser berechnet die Werte auf Basis einer übergebenen Liste an NumberEntries.
<br><br>
Eine weitere wichtige Komponente der Anwendung ist der `MyApplicationRunner`, der über den `NumberEntryService` eine zufällige Anzahl an NumberEntries mit zufälligem Wert erstellt. Dabei wird ebenfalls die `GuessingAverageProperties` Klasse verwendet, um die wichtigen Parameter aus der `application.properties` auszulesen.
