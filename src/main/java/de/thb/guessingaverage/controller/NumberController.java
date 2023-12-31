package de.thb.guessingaverage.controller;

import de.thb.guessingaverage.configuration.GuessingAverageProperties;
import de.thb.guessingaverage.controller.form.NumberEntryFormModel;
import de.thb.guessingaverage.services.NumberEntryService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@AllArgsConstructor
public class NumberController {
    private final NumberEntryService numberEntryService;
    private final GuessingAverageProperties properties;

    @GetMapping("/")
    public String controlNumber(Model model){
        model.addAttribute("minNumber", numberEntryService.getTotalMinNumber());
        model.addAttribute("maxNumber", numberEntryService.getTotalMaxNumber());
        model.addAttribute("medianNumber", numberEntryService.calculateTotalMedianNumber());
        model.addAttribute("properties", properties);

        return "guessing-average.html";
    }

    @PostMapping("/")
    public String addNumber(@ModelAttribute NumberEntryFormModel form, Model model){
        numberEntryService.addNumberFromNumberEntryFromModel(form);

        model.addAttribute("minNumber", numberEntryService.getTotalMinNumber());
        model.addAttribute("maxNumber", numberEntryService.getTotalMaxNumber());
        model.addAttribute("medianNumber", numberEntryService.calculateTotalMedianNumber());
        model.addAttribute("averageNumber", numberEntryService.calculateTotalAverageNumber());
        model.addAttribute("properties", properties);
        model.addAttribute("number", form.getNumber());

        if(numberEntryService.getTotalNumberOfNumberEntries() % properties.getRandomNumbersFrequency() == 0){
            numberEntryService.createRandomNumberOfRandomEntries(properties.getMinNumber(), properties.getMaxNumber(), properties.getMinValue(), properties.getMaxValue());
            model.addAttribute("newNumbersAdded", true);
        }

        return "guessing-average.html";
    }

}
