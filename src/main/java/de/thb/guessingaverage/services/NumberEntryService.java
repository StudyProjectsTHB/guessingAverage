package de.thb.guessingaverage.services;

import de.thb.guessingaverage.controller.form.NumberEntryFormModel;
import de.thb.guessingaverage.repositories.NumberEntryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import de.thb.guessingaverage.entities.NumberEntry;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

@Service
public class NumberEntryService {
    private final NumberEntryCalculationService numberEntryCalculationService;
    private final NumberEntryRepository numberEntryRepository;
    private final SecureRandom random;

    public NumberEntryService(NumberEntryCalculationService numberEntryCalculationService, NumberEntryRepository numberEntryRepository){
        this.numberEntryCalculationService = numberEntryCalculationService;
        this.numberEntryRepository = numberEntryRepository;
        this.random = new SecureRandom();
    }

    public float calculateTotalAverageNumber(){
        return numberEntryCalculationService.calculateAverageNumber(numberEntryRepository.findAll());
    }

    public float calculateTotalMedianNumber(){
        return numberEntryCalculationService.calculateMedianNumber(numberEntryRepository.findAll());
    }

    public float getTotalMaxNumber(){
        return numberEntryCalculationService.getMaxNumber(numberEntryRepository.findAll());
    }

    public float getTotalMinNumber(){
        return numberEntryCalculationService.getMinNumber(numberEntryRepository.findAll());
    }

    public void addNumberFromNumberEntryFromModel(NumberEntryFormModel form){
        numberEntryRepository.save(new NumberEntry(LocalDateTime.now(), form.getNumber()));
    }

    public long getTotalNumberOfNumberEntries(){
        return numberEntryRepository.count();
    }

    public NumberEntry generateRandomNumberEntry(float minValue, float maxValue){
        float randomValue = minValue + random.nextFloat() * (maxValue - minValue);
        return new NumberEntry(LocalDateTime.now(), randomValue);
    }

    public List<NumberEntry> createRandomNumberOfRandomEntries(int minNumber, int maxNumber, float minValue, float maxValue){
        List<NumberEntry> numberEntries = new LinkedList<NumberEntry>();

        int randomNumber = random.nextInt(maxNumber + 1 - minNumber) + minNumber;

        for(int i = 0; i < randomNumber; i++){
            numberEntries.add(generateRandomNumberEntry(minValue, maxValue));
        }

        numberEntryRepository.saveAll(numberEntries);

        return numberEntries;
    }
}
