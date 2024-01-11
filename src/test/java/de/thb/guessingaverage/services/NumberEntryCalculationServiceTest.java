package de.thb.guessingaverage.services;

import de.thb.guessingaverage.entities.NumberEntry;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.ArrayList;
import java.util.List;

@SpringBootTest
class NumberEntryCalculationServiceTest {

    @Autowired
    private NumberEntryCalculationService numberEntryCalculationService;

    @Test
    void test_average_calculation_with_entries_positive() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 0.3f));
        numberEntries.add(new NumberEntry(null, 0.5f));
        numberEntries.add(new NumberEntry(null, 0.4f));

        Assertions.assertEquals(0.4f, numberEntryCalculationService.calculateAverageNumber(numberEntries), "Given average is not the real average.");
    }

    @Test
    void test_average_calculation_with_entries_big() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 120));
        numberEntries.add(new NumberEntry(null, 120));
        numberEntries.add(new NumberEntry(null, 121));
        numberEntries.add(new NumberEntry(null, 121));

        Assertions.assertEquals(120.5f, numberEntryCalculationService.calculateAverageNumber(numberEntries), "Given average is not the real average.");
    }

    @Test
    void test_average_calculation_with_entries_mixed() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, -4.5f));
        numberEntries.add(new NumberEntry(null, 0));
        numberEntries.add(new NumberEntry(null, 10));
        numberEntries.add(new NumberEntry(null, -100));

        Assertions.assertEquals(-23.625f, numberEntryCalculationService.calculateAverageNumber(numberEntries), "Given average is not the real average.");
    }

    @Test
    void test_average_calculation_with_entries_zeros() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 0));
        numberEntries.add(new NumberEntry(null, 0));
        numberEntries.add(new NumberEntry(null, 0));
        numberEntries.add(new NumberEntry(null, -0));

        Assertions.assertEquals(0, numberEntryCalculationService.calculateAverageNumber(numberEntries), "Given average is not the real average.");
    }

    @Test
    void test_average_calculation_without_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        Assertions.assertEquals(0, numberEntryCalculationService.calculateAverageNumber(numberEntries), "Given average should be 0 in case of no given entries.");
    }

    @Test
    void test_average_calculation_with_null() {
        Assertions.assertEquals(0, numberEntryCalculationService.calculateAverageNumber(null), "Given average should be 0 in case of null as given entries.");
    }

    @Test
    void test_median_calculation_with_odd_number_of_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 1));
        numberEntries.add(new NumberEntry(null, 3));
        numberEntries.add(new NumberEntry(null, 10));

        Assertions.assertEquals(3, numberEntryCalculationService.calculateMedianNumber(numberEntries), "Given median is not the real median for an odd number of entries.");
    }

    @Test
    void test_median_calculation_with_even_number_of_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 1));
        numberEntries.add(new NumberEntry(null, 3));
        numberEntries.add(new NumberEntry(null, 4));
        numberEntries.add(new NumberEntry(null, 10));

        Assertions.assertEquals(3.5, numberEntryCalculationService.calculateMedianNumber(numberEntries), "Given median is not the real median for an even number of entries. Should be the average of the 2 middle numbers.");
    }

    @Test
    void test_median_calculation_with_no_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        Assertions.assertEquals(0, numberEntryCalculationService.calculateMedianNumber(numberEntries), "Given median should be 0 in case of no given entries.");
    }

    @Test
    void test_median_calculation_with_null() {
        Assertions.assertEquals(0, numberEntryCalculationService.calculateMedianNumber(null), "Given median should be 0 in case of null as given entries.");
    }

    @Test
    void test_max_number_with_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 1));
        numberEntries.add(new NumberEntry(null, 3));
        numberEntries.add(new NumberEntry(null, 10));

        Assertions.assertEquals(10, numberEntryCalculationService.getMaxNumber(numberEntries), "Given max value is not the real max value.");
    }

    @Test
    void test_max_number_with_no_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();

        Assertions.assertEquals(0, numberEntryCalculationService.getMaxNumber(numberEntries), "Given max value should be 0 in case of no given entries.");
    }

    @Test
    void test_max_number_with_null() {
        Assertions.assertEquals(0, numberEntryCalculationService.getMaxNumber(null), "Given max value should be 0 in case of null as given entries.");
    }

    @Test
    void test_min_number_with_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();
        numberEntries.add(new NumberEntry(null, 1));
        numberEntries.add(new NumberEntry(null, 3));
        numberEntries.add(new NumberEntry(null, 10));

        Assertions.assertEquals(1, numberEntryCalculationService.getMinNumber(numberEntries), "Given min value is not the real min value.");
    }

    @Test
    void test_min_number_with_no_entries() {
        List<NumberEntry> numberEntries = new ArrayList<>();

        Assertions.assertEquals(0, numberEntryCalculationService.getMinNumber(numberEntries), "Given min value should be 0 in case of no given entries.");
    }

    @Test
    void test_min_number_with_null() {
        Assertions.assertEquals(0, numberEntryCalculationService.getMinNumber(null), "Given min value should be 0 in case of null as given entries.");
    }
}
