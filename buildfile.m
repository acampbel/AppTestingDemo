function plan = buildfile
import matlab.buildtool.tasks.*;

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("test") = TestTask(TestResults="test-results.pdf");

plan("markdown").Inputs = "**/*.mlx";
plan("markdown").Outputs = replace(plan("markdown").Inputs, ".mlx",".md");

plan("jupyter").Inputs = "**/*.mlx";
plan("jupyter").Outputs = replace(plan("jupyter").Inputs, ".mlx",".ipynb");

end

function markdownTask(ctx)
% Generate markdown from all mlx files

exportHelper(ctx, "markdown");
end

function jupyterTask(ctx)
% Generate jupyter notebooks from all mlx files

exportHelper(ctx, "jupyter");
end

function exportHelper(ctx, type)
% Generate markdown from all mlx files

mlxFiles = ctx.Task.Inputs.paths;
outFiles = ctx.Task.Outputs.paths;
for idx = 1:numel(mlxFiles) 
    disp("Building "+ type + " file from " + mlxFiles(idx))
    export(mlxFiles(idx), outFiles(idx), Run=true);
end
end
