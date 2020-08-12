var documenterSearchIndex = {"docs":
[{"location":"#Hyperparameters.jl-1","page":"Home","title":"Hyperparameters.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Modules = [Hyperparameters]","category":"page"},{"location":"#Hyperparameters.HYPERPARAMETERS","page":"Home","title":"Hyperparameters.HYPERPARAMETERS","text":"HYPERPARAMETERS::Dict{Symbol, Any}\n\nCollection of all the hyperparameters, and their values accessed during this run.\n\n\n\n\n\n","category":"constant"},{"location":"#Hyperparameters.hyperparam-Tuple{Symbol}","page":"Home","title":"Hyperparameters.hyperparam","text":"hyperparam([T::Type=Float64,] name; prefix=\"SM_HP_\"))\n\nLoad the hyperparameter with the given name from the environment variable named with the name in uppercase, and prefixed with prefix parsing it as type T (default: Float64).\n\nAlso stores the hyperparameter and its value in the global HYPERPARAMETERS dictionary. This function is generally expected to be used with SageMaker, and supplies the default prefix for it.\n\nusing Hyperparameters\nENV[\"HP_POWER_LEVEL\"] = \"9001\"\nhyperparam(:power_level; prefix=\"HP_\")\n\n# output\n9001.0\n\n\n\n\n\n","category":"method"},{"location":"#Hyperparameters.hyperparams-Tuple{Vararg{Symbol,N} where N}","page":"Home","title":"Hyperparameters.hyperparams","text":"hyperparams(names...; prefix=\"SM_HP_\")\n\nAs per hyperparam, but taking multiple names and returning a NamedTuple.\n\nusing Hyperparameters\nENV[\"SM_HP_A\"] = \"5\"\nENV[\"SM_HP_B\"] = \"1.22\"\nhyperparams(:a, :b, types=[Int, Float64])\n\n# output\n(a = 5, b = 1.22)\n\nAlso stores the hyperparameters and their values in the global HYPERPARAMETERS dictionary.\n\n\n\n\n\n","category":"method"},{"location":"#Hyperparameters.report_hyperparameters-Tuple{FilePathsBase.AbstractPath}","page":"Home","title":"Hyperparameters.report_hyperparameters","text":"report_hyperparameters(save_dir::AbstractPath)\n\nSaves the cached HYPERPARAMETERS to a JSON file named \"hyperparameters.json\" in the save_dir and prints each key-value pair to the logger.\n\nThe regex to extract the components is: hyperparameters: (?<key>)=(?<value>).\n\n\n\n\n\n","category":"method"},{"location":"#Hyperparameters.save_hyperparam-Tuple{Symbol,Any}","page":"Home","title":"Hyperparameters.save_hyperparam","text":"save_hyperparam(name::Symbol, value, prefix::AbstractString=\"\")\n\nSave value to the enviroment variables and the global HYPERPARAMETERS dictionary.\n\n\n\n\n\n","category":"method"}]
}
