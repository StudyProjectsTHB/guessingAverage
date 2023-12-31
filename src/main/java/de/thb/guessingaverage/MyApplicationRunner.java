package de.thb.guessingaverage;

import de.thb.guessingaverage.configuration.GuessingAverageProperties;
import de.thb.guessingaverage.services.NumberEntryService;
import lombok.AllArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@AllArgsConstructor
public class MyApplicationRunner implements ApplicationRunner {
    private final NumberEntryService numberEntryService;
    private final GuessingAverageProperties guessingAverageProperties;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        if (numberEntryService.getTotalNumberOfNumberEntries() == 0) {
            numberEntryService.createRandomNumberOfRandomEntries(guessingAverageProperties.getMinNumber(), guessingAverageProperties.getMaxNumber(), guessingAverageProperties.getMinValue(), guessingAverageProperties.getMaxValue());
        }
    }
}
