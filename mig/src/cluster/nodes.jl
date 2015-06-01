
# sets up an MProb on each node


if ENV["USER"] == "florian_o"
	push!(DL_LOAD_PATH, "/home/florian_o/local/lib")
elseif ENV["USER"] == "eisuc151"
	push!(DL_LOAD_PATH, "/home/eisuc151/local/lib")
elseif ENV["USER"] == "uctpfos"
	push!(DL_LOAD_PATH, "/home/eisuc151/local/hdf5/lib")
end


using mig, MOpt


indir, outdir = mig.setPaths()
moms = mig.DataFrame(mig.read_rda(joinpath(indir,"moments.rda"))["m"])
mig.names!(moms,[:name,:value,:weight])
# subsetting moments
dont_use= ["lm_w_intercept","move_neg_equity","q25_move_distance","q50_move_distance","q75_move_distance"]
for iw in moms[:name]
	if contains(iw,"wealth") 
		push!(dont_use,iw)
	end
end
use_names = setdiff(moms[:name],dont_use)
moms_use = moms[findin(moms[:name],use_names) ,:]

# initial value
p0 = mig.Param(2)
pb = Dict{ASCIIString,Array{Float64}}()
pb["xi1"] = [p0.xi1, 0.0,0.02]
pb["xi2"] = [p0.xi2, 0.0,0.1]
pb["omega2"] = [p0.omega2, 2.0,4.1]
pb["MC0"] = [p0.MC0, 2.0,4.0]
pb["MC1"] = [p0.MC1, 0.0,0.04]
pb["MC2"] = [p0.MC2, 0.0,0.01]
pb["MC3"] = [p0.MC3, 0.0,1]
pb["MC4"] = [p0.MC4, 0.0,1]
pb["taudist"] = [p0.taudist, 0.0,1]

mprob = MOpt.MProb() 
MOpt.addSampledParam!(mprob,pb) 
MOpt.addMoment!(mprob,moms_use) 
MOpt.addEvalFunc!(mprob,mig.objfunc)

