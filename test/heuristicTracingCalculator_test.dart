import 'package:covi/utils/heuristicTracingCalculator.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test positive diagnostic", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 3,
      'old_symptomatic_risk': 3,
      'recommandation_level': 0,
      'covid_test_result_is_positive': true,
      'covid_test_result_date': "2020-07-07",
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 15);
    expect(calculator.userData.recommandationLevel, 3);
  });

  test("test positive diagnostic older than 14 days and no symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 3,
      'old_symptomatic_risk': 3,
      'recommandation_level': 0,
      'covid_test_result_is_positive': true,
      'covid_test_result_date': "2020-06-15",
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030B030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 6);
    expect(calculator.userData.recommandationLevel, 2);
  });

  test("test negative diagnostic with no symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 6,
      'old_symptomatic_risk': 6,
      'recommandation_level': 0,
      'covid_test_result_is_positive': false,
      'covid_test_result_date': "2020-07-07",
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 1);
    expect(calculator.userData.recommandationLevel, 0);
  });

  test("test negative diagnostic with old symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 6,
      'old_symptomatic_risk': 6,
      'recommandation_level': 0,
      'covid_test_result_is_positive': false,
      'covid_test_result_date': "2020-07-07",
      'symptoms': true,
      'symptoms_since': "2020-07-05",
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': true,
      'cough': true,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 1);
    expect(calculator.userData.recommandationLevel, 0);
  });

  test("test negative diagnostic with new symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 5,
      'old_symptomatic_risk': 5,
      'recommandation_level': 0,
      'covid_test_result_is_positive': false,
      'covid_test_result_date': "2020-07-06",
      'symptoms': true,
      'symptoms_since': "2020-07-08",
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': true,
      'cough': true,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 7);
    expect(calculator.userData.recommandationLevel, 2);
  });

  test("test severe symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 3,
      'old_symptomatic_risk': 3,
      'recommandation_level': 0,
      'covid_test_result_is_positive': null,
      'covid_test_result_date': null,
      'symptoms': true,
      'symptoms_since': "2020-07-07",
      'severe_chest_pain': true,
      'hard_time_waking_up': true,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 12);
    expect(calculator.userData.recommandationLevel, 3);
  });

  test("test light symptoms", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 3,
      'old_symptomatic_risk': 3,
      'recommandation_level': 0,
      'covid_test_result_is_positive': null,
      'covid_test_result_date': null,
      'symptoms': true,
      'symptoms_since': "2020-07-07",
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': true,
      'cough': true,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': true,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 7);
    expect(calculator.userData.recommandationLevel, 2);
  });

  test("test encounter risk factor R' > R", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 3,
      'old_symptomatic_risk': 3,
      'recommandation_level': 0,
      'covid_test_result_is_positive': null,
      'covid_test_result_date': null,
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 10);
    expect(calculator.userData.recommandationLevel, 3);
  });

  test("test encounter risk factor R' < R", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 11,
      'old_symptomatic_risk': 11,
      'recommandation_level': 1,
      'covid_test_result_is_positive': null,
      'covid_test_result_date': null,
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F030F030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 11);
    expect(calculator.userData.recommandationLevel, 3);
  });

  test("test 2 encounter risk factor R' > R", () {
    // Arrange
    Map<String, dynamic> userDataJson = {
      'new_symptomatic_risk': 5,
      'old_symptomatic_risk': 5,
      'recommandation_level': 0,
      'covid_test_result_is_positive': null,
      'covid_test_result_date': null,
      'symptoms': null,
      'symptoms_since': null,
      'severe_chest_pain': null,
      'hard_time_waking_up': null,
      'feeling_confused': null,
      'lost_consciousness': null,
      'difficulty_breathing': null,
      'difficulty_breathing_severity': null,
      'sneezing': null,
      'fever': null,
      'cough': null,
      'muscle_aches': null,
      'fatigue': null,
      'headaches': null,
      'sore_throat': null,
      'runny_nose': null,
      'nausea': null,
      'diarrhea': null,
      'chills': null,
      'loss_of_smell': null,
      'loss_of_appetite': null,
    };

    UserData userData = new UserData.fromJson(userDataJson);

    // Act
    HeuristicTracingCalculator calculator =
        new HeuristicTracingCalculator(userData);
    calculator.heuristicTracingAlgo("000F0309030407000000000000000000");

    // Assert
    expect(calculator.userData.newSymptomaticRisk, 5);
    expect(calculator.userData.recommandationLevel, 1);
  });
}
