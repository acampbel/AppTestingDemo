classdef PatientsDisplayTest < matlab.uitest.TestCase
    properties
        App
    end

    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = PatientsDisplay;
            testCase.captureFigure("Launch");
            testCase.addTeardown(@delete,testCase.App)
            testCase.addTeardown(@captureFigure, testCase, "Teardown");
        end
        function takeScreenshotOnFailure(testCase)
            testCase.onFailure(ScreenshotDiagnostic)
        end
    end

    methods (Test)
        function testTab(testCase)
            % Choose the Data tab
            dataTab = testCase.App.DataTab;
            testCase.captureFigure("testTab-choose-before");
            testCase.choose(dataTab)
            testCase.captureFigure("testTab-choose-before");

            % Verify that the tab has the expected title
            testCase.verifyEqual( ...
                testCase.App.TabGroup.SelectedTab.Title,'Data')
        end

        function testPlottingOptions(testCase)
            % Press the Histogram radio button
            testCase.captureFigure("testPlottingOptions-press-histo-before");
            testCase.press(testCase.App.HistogramButton)
            testCase.captureFigure("testPlottingOptions-press-histo-after");

            % Verify that the x-axis label changed from Weight to Systolic
            testCase.verifyEqual(testCase.App.UIAxes.XLabel.String, ...
                'Systolic')

            % Change the bin width to 9
            testCase.captureFigure("testPlottingOptions-choose-bin-width-before");
            testCase.choose(testCase.App.BinWidthSlider,9)
            testCase.captureFigure("testPlottingOptions-choose-bin-width-after");

            % Verify the number of bins
            testCase.verifyEqual(testCase.App.UIAxes.Children.NumBins,4);
            
            % Highlight a failure
            testCase.verifyEqual(testCase.App.UIAxes.Children.NumBins,5, ...
                "Deliberate failure to highlight screenshot on failure");
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
            testCase.captureFigure("testBloodPressure-choose-diastolic-before");
            testCase.choose(testCase.App.BloodPressureSwitch,'Diastolic')
            testCase.captureFigure("testBloodPressure-choose-diastolic-after");

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
            testCase.captureFigure("testGender-include-female-before");
            testCase.choose(testCase.App.FemaleCheckBox)
            testCase.captureFigure("testGender-include-female-after");

            % Verify the number of displayed data sets and the color
            % representing the female data
            testCase.assertNumElements(ax.Children,2)
            testCase.verifyEqual(ax.Children(1).CData,[1 0 0])

            % Exclude the male data
            testCase.captureFigure("testGender-exclude-male-before");
            testCase.choose(testCase.App.MaleCheckBox,false)
            testCase.captureFigure("testGender-exclude-male-after");
            
            % Verify the number of displayed data sets and the number of
            % scatter points
            testCase.verifyNumElements(ax.Children,1)
            testCase.verifyNumElements(ax.Children.XData,53)
        end
    end
    methods(Access=private)
        function captureFigure(testCase, prefix)
            fig = testCase.App.PatientsDisplayUIFigure;
            testCase.log(1, [prefix, FigureDiagnostic(fig, ...
                Prefix=prefix, Formats="png")]);
        end
    end

end

function d = FigureDiagnostic(varargin)
d = matlab.unittest.diagnostics.FigureDiagnostic(varargin{:});
end

function d = ScreenshotDiagnostic(varargin)
d = matlab.unittest.diagnostics.ScreenshotDiagnostic(varargin{:});
end
