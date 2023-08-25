classdef PatientsDisplayTest < matlab.uitest.TestCase
    properties
        App
    end

    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = PatientsDisplay;
            testCase.addTeardown(@delete,testCase.App)
        end
        function takeScreenshotOnFailure(testCase)
            testCase.onFailure(matlab.unittest.diagnostics.ScreenshotDiagnostic)
        end
    end

    methods (Test)
        function testTab(testCase)
            % Choose the Data tab
            dataTab = testCase.App.DataTab;
            testCase.choose(dataTab)

            % Verify that the tab has the expected title
            testCase.verifyEqual( ...
                testCase.App.TabGroup.SelectedTab.Title,'Data')
        end

        function testPlottingOptions(testCase)
            % Press the Histogram radio button
            testCase.press(testCase.App.HistogramButton)

            % Verify that the x-axis label changed from Weight to Systolic
            testCase.verifyEqual(testCase.App.UIAxes.XLabel.String, ...
                'Systolic')

            % Change the bin width to 9
            testCase.choose(testCase.App.BinWidthSlider,9)

            % Verify the number of bins
            testCase.verifyEqual(testCase.App.UIAxes.Children.NumBins,4)
        end

        function testBloodPressure(testCase)
            % Extract the blood pressure data from the app
            t = testCase.App.DataTab.Children.Data;
            t.Gender = categorical(t.Gender);
            allMales = t(t.Gender == "Male",:);
            maleDiastolicData = allMales.Diastolic';
            maleSystolicData = allMales.Systolic';

            % Verify the y-axis label and that the male Systolic data is
            % displayed
            ax = testCase.App.UIAxes;
            testCase.verifyEqual(ax.YLabel.String,'Systolic')
            testCase.verifyEqual(ax.Children.YData,maleSystolicData)

            % Switch to Diastolic readings
            testCase.choose(testCase.App.BloodPressureSwitch,'Diastolic')

            % Verify the y-axis label and that the male Diastolic data
            % is displayed
            testCase.verifyEqual(ax.YLabel.String,'Diastolic')
            testCase.verifyEqual(ax.Children.YData,maleDiastolicData)
        end

        function testGender(testCase)
            
            % Verify the number of male scatter points
            ax = testCase.App.UIAxes;
            testCase.verifyNumElements(ax.Children.XData,47)

            % Include the female data
            testCase.choose(testCase.App.FemaleCheckBox)

            % Verify the number of displayed data sets and the color
            % representing the female data
            testCase.assertNumElements(ax.Children,2)
            testCase.verifyEqual(ax.Children(1).CData,[1 0 0])

            % Exclude the male data
            testCase.choose(testCase.App.MaleCheckBox,false)

            % Verify the number of displayed data sets and the number of
            % scatter points
            testCase.verifyNumElements(ax.Children,1)
            testCase.verifyNumElements(ax.Children.XData,50)
        end
    end
end
