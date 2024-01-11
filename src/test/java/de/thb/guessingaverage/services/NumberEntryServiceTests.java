package de.thb.guessingaverage.services;

import de.thb.guessingaverage.controller.form.NumberEntryFormModel;
import de.thb.guessingaverage.repositories.NumberEntryRepository;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;


@SpringBootTest
class NumberEntryServiceTests {

    @Autowired
    private NumberEntryService numberEntryService;

    @Autowired
    private NumberEntryRepository numberEntryRepository;


    @Test
    void test_add_number() {
        NumberEntryFormModel form = new NumberEntryFormModel();
        float number = 1.f;
        form.setNumber(number);
        numberEntryService.addNumberFromNumberEntryFromModel(form);
        number = 2.5f;
        form.setNumber(number);
        numberEntryService.addNumberFromNumberEntryFromModel(form);
        Assertions.assertEquals(number, numberEntryRepository.findTopByOrderByIdDesc().getNumber(), "Number should be added to the database.");
    }

    @AfterEach
    public void tearDown() {
        numberEntryRepository.delete(numberEntryRepository.findTopByOrderByIdDesc());
        numberEntryRepository.delete(numberEntryRepository.findTopByOrderByIdDesc());
    }
}

