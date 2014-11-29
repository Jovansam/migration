

# miscellaneous includes

# objective function to work with mopt
function objfunc2(ev::Eval)

	start(ev)
	info("in objective function 2")

	# info("start model solution")
	time0 = time()
	p = Param(2)	# create a default param type
	pd = ev.params	# get all params as a dict
	update!(p,pd)	# update with values changed by the optimizer
	m = Model(p)
	mig.solve!(m,p)
	s   = simulate(m,p)
	mms = computeMoments(s,p,m)	
	# mms   = simulate_parts(m,p,5)	# simulate and compute moments in 5 pars

	mom2 = join(mom,mms,on=:moment)
	insert!(mom2,6,DataArray(Float64,nrow(mom2)),:perc)
	insert!(mom2,6,DataArray(Float64,nrow(mom2)),:sqdist)

	# get subset of moments
	subset = findin(mom2[:moment],whichmom)

	# get percentage difference
	mom2[subset,:perc] = (mom2[subset,:data_value] - mom2[subset,:model_value]) ./ mom2[subset,:data_value]

	# get mean squared distance over standard edeivation
	mom2[subset,:sqdist] = ((mom2[subset,:data_value] - mom2[subset,:model_value])./ mom2[subset,:data_sd] ).^2

	fval = mean(mom2[subset,:sqdist]) / 1000
	# fval = mean(abs(mom2[subset,:perc]))

    mout = transpose(mom2[[:moment,:model_value]],1)

    if Sys.OS_NAME == :Darwin
	    showall(mom2[:,[:moment,:data_value,:model_value,:sqdist]])
	    println(p)
		s2 = @where(s,(:year.>1996) & (!isna(:cohort)))
		showall(@by(s2,[:realage],own=mean(:own),move=mean(:move),buy=mean((:h.==0)&(:hh.==1)),sell=mean((:h.==1)&(:hh.==0))))
		showall(hcat(@by(@where(s2,:own.==true),:realage,move_owner=mean(:move)),@by(@where(s2,:own.==false),:realage,move_renter=mean(:move))))
	    if get(opts[1],"printmoms",false) 
	    	d = Dict()
	    	for ea in eachrow(mom2)
	    		ea[:moment] = replace(ea[:moment],"[","")
	    		ea[:moment] = replace(ea[:moment],"]","")
	    		ea[:moment] = replace(ea[:moment],"(","")
	    		ea[:moment] = replace(ea[:moment],",","_")
	    		d[ea[:moment]] = ["data" => ea[:data_value], "data_sd" => ea[:data_sd], "model" => ea[:model_value], "model_sd" => ea[:model_sd], "perc"=>ea[:perc]]

	    	end
	    	# change age brackets

	    	f = open("/Users/florianoswald/Dropbox/mobility/output/model/fit/moms.json","w")
	    	JSON.print(f,d)
	    	close(f)
    		# writetable("/Users/florianoswald/Dropbox/mobility/output/model/fit/moms.csv",mom2)
	    end
	    if get(opts[1],"plotsim",false) 
	   		simplot(s[!isna(s[:cohort]),:],5)
	   	end
	    println()
	end

	status = 1
	# if isnan(fval)
	# 	status = -1
	# end

	if get(opts[1],"printlevel",0) > 0
		println("objfunc runtime = $(time()-time0)")
		println("objfunc value = $(fval)")
	end
	time1 = round(time()-time0)
	ret = ["value" => fval, "params" => deepcopy(pd), "time" => time1, "status" => status, "moments" => mout]
	return ret
end
function objfunc(pd::Dict,mom::DataFrame,whichmom::Array{ASCIIString,1},opts...)


	# info("start model solution")
	time0 = time()
	p = Param(2)	# create a default param type
	update!(p,pd)	# update with values changed by the optimizer
	m = Model(p)
	mig.solve!(m,p)
	s   = simulate(m,p)
	mms = computeMoments(s,p,m)	
	# mms   = simulate_parts(m,p,5)	# simulate and compute moments in 5 pars

	mom2 = join(mom,mms,on=:moment)
	insert!(mom2,6,DataArray(Float64,nrow(mom2)),:perc)
	insert!(mom2,6,DataArray(Float64,nrow(mom2)),:sqdist)

	# get subset of moments
	subset = findin(mom2[:moment],whichmom)

	# get percentage difference
	mom2[subset,:perc] = (mom2[subset,:data_value] - mom2[subset,:model_value]) ./ mom2[subset,:data_value]

	# get mean squared distance over standard edeivation
	mom2[subset,:sqdist] = ((mom2[subset,:data_value] - mom2[subset,:model_value])./ mom2[subset,:data_sd] ).^2

	fval = mean(mom2[subset,:sqdist]) 
	# fval = mean(abs(mom2[subset,:perc]))

    mout = transpose(mom2[[:moment,:model_value]],1)

    if Sys.OS_NAME == :Darwin
	    showall(mom2[:,[:moment,:data_value,:model_value,:sqdist]])
	    println(p)
		s2 = @where(s,(:year.>1996) & (!isna(:cohort)))
		showall(@by(s2,[:realage],own=mean(:own),move=mean(:move),buy=mean((:h.==0)&(:hh.==1)),sell=mean((:h.==1)&(:hh.==0))))
		showall(hcat(@by(@where(s2,:own.==true),:realage,move_owner=mean(:move)),@by(@where(s2,:own.==false),:realage,move_renter=mean(:move))))
	    if get(opts[1],"printmoms",false) 
	    	d = Dict()
	    	for ea in eachrow(mom2)
	    		ea[:moment] = replace(ea[:moment],"[","")
	    		ea[:moment] = replace(ea[:moment],"]","")
	    		ea[:moment] = replace(ea[:moment],"(","")
	    		ea[:moment] = replace(ea[:moment],",","_")
	    		d[ea[:moment]] = ["data" => ea[:data_value], "data_sd" => ea[:data_sd], "model" => ea[:model_value], "model_sd" => ea[:model_sd], "perc"=>ea[:perc]]

	    	end
	    	# change age brackets

	    	f = open("/Users/florianoswald/Dropbox/mobility/output/model/fit/moms.json","w")
	    	JSON.print(f,d)
	    	close(f)
    		# writetable("/Users/florianoswald/Dropbox/mobility/output/model/fit/moms.csv",mom2)
	    end
	    if get(opts[1],"plotsim",false) 
	   		simplot(s[!isna(s[:cohort]),:],5)
	   	end
	    println()
	end

	status = 1
	# if isnan(fval)
	# 	status = -1
	# end

	if get(opts[1],"printlevel",0) > 0
		println("objfunc runtime = $(time()-time0)")
		println("objfunc value = $(fval)")
	end
	time1 = round(time()-time0)
	ret = ["value" => fval, "params" => deepcopy(pd), "time" => time1, "status" => status, "moments" => mout]
	return ret
end

function mywrap()
	p = mig.Param(2)
	m = mig.Model(p)
    mig.solve!(m,p)
end


function runSim()
	p = Param(2)
	m = Model(p)
    solve!(m,p)
	s   = simulate(m,p)
	s = s[!isna(s[:cohort]),:]
	s2 = @where(s,:year.>1996)
	showall(@by(s2,[:own,:realage],m=mean(:move)))
	showall(@by(s2,[:realage],own=mean(:own),buy=mean((:h.==0)&(:hh.==1)),sell=mean((:h.==1)&(:hh.==0))))
	own=@by(s2,[:realage],m=mean(:own))
	mig.plot(own[:realage],own[:m])
	figure()
	simplot(s,5)
	x=computeMoments(s,p,m)
	showall(x)
	return s
end


# single test run of objective
function runObj(printmoms::Bool)
	# run objective
	p2 = Dict{ASCIIString,Float64}()
	if Sys.OS_NAME == :Darwin
		indir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model/data_repo/in_data_jl")
	elseif Sys.OS_NAME == :Windows
		indir = "C:\\Users\\florian_o\\Dropbox\\mobility\\output\\model\\data_repo\\in_data_jl"
	else
		indir = joinpath(ENV["HOME"],"data_repo/mig/in_data_jl")
	end
	moms = mig.DataFrame(mig.read_rda(joinpath(indir,"moments.rda"))["m"])
	# subsetting moments
	dont_use= ["lm_w_intercept","move_neg_equity","q25_move_distance","q50_move_distance","q75_move_distance"]
	for iw in moms[:moment]
		if contains(iw,"wealth") 
			push!(dont_use,iw)
		end
	end
	submom = setdiff(moms[:moment],dont_use)

 	objfunc_opts = ["printlevel" => 1,"printmoms"=>printmoms]
	@time x = mig.objfunc(p2,moms,submom,objfunc_opts)

	return x
end

function runObj(printmoms::Bool,p2::Dict)
	# run objective
	if Sys.OS_NAME == :Darwin
		indir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model/data_repo/in_data_jl")
	elseif Sys.OS_NAME == :Windows
		indir = "C:\\Users\\florian_o\\Dropbox\\mobility\\output\\model\\data_repo\\in_data_jl"
	else
		indir = joinpath(ENV["HOME"],"data_repo/mig/in_data_jl")
	end
	moms = mig.DataFrame(mig.read_rda(joinpath(indir,"moments.rda"))["m"])
	# subsetting moments
	dont_use= ["lm_w_intercept","move_neg_equity","q25_move_distance","q50_move_distance","q75_move_distance"]
	for iw in moms[:moment]
		if contains(iw,"wealth") 
			push!(dont_use,iw)
		end
	end
	submom = setdiff(moms[:moment],dont_use)

 	objfunc_opts = ["printlevel" => 1,"printmoms"=>printmoms]
	@time x = mig.objfunc(p2,moms,submom,objfunc_opts)

	return x
end
		
# asset grid scaling
function scaleGrid(lb::Float64,ub::Float64,n::Int,order::Int,cutoff::Float64,partition=0.5) 
	out = zeros(n)
	if order==1
		off = 1
		if lb<0 
			off = 1 - lb #  adjust in case of neg bound
		end
		out[1] = log(lb + off) 
		out[n] = log(ub + off) 
		out    = linspace(out[1],out[n],n)
		out    = exp(out) - off  
	elseif order==2
		off = 1
		if lb<0 
			off = 1 - lb #  adjust in case of neg bound
		end
		out[1] = log( log(lb + off) + off )
		out[n] = log( log(ub + off) + off )
		out    = linspace(out[1],out[n],n)
		out    = exp( exp(out) - off ) - off
	elseif order == 3
		npos = int(ceil(n*partition))
		nneg = n-npos
		if nneg < 1
			error("need at least one point in neg space")
		end
		nneg += 1
		# positive: log scale
		pos = exp( linspace(log(cutoff),log( ub + 1) ,npos) ) -1 
		# negative: linear scale
		neg = linspace(lb,cutoff,nneg)
		return [neg[1:(nneg-1)],pos]
	else
		error("supports only double log grid")
	end
end


# converts
# function convert(::Type{DataFrame},cc::CoefTable)
# 	DataFrame(Variable=cc.rownms,Estimate=cc.mat[:,1],StdError=cc.mat[:,2],tval=cc.mat[:,3],pval=cc.mat[:,4])
# end

# convert(::Type{Array{Int64,1}}, PooledDataArray{Int64,Uint32,1})
mylog(x::Float64) = ccall((:log, "libm"), Float64, (Float64,), x)
myexp(x::Float64) = ccall((:exp, "libm"), Float64, (Float64,), x)
mylog2(x::Float64) = ccall(:log, Cdouble, (Cdouble,), x)
myexp2(x::Float64) = ccall(:exp, Cdouble, (Cdouble,), x)


function setPaths()
# get moments from dropbox:
	if Sys.OS_NAME == :Darwin
		indir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model/data_repo/in_data_jl")
		outdir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model/data_repo/out_data_jl")
	elseif Sys.OS_NAME == :Windows
		indir = "C:\\Users\\florian_o\\Dropbox\\mobility\\output\\model\\data_repo\\in_data_jl"
		outdir = "C:\\Users\\florian_o\\Dropbox\\mobility\\output\\model\\data_repo\\out_data_jl"
	else
		indir = joinpath(ENV["HOME"],"data_repo/mig/in_data_jl")
		outdir = joinpath(ENV["HOME"],"data_repo/mig/out_data_jl")
	end
	return (indir,outdir)
end

# set outpath rel to dropbox/mobility/output/model
function setPaths(p::ASCIIString)
	if Sys.OS_NAME == :Darwin
		indir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model/data_repo/in_data_jl")
		outdir = joinpath(ENV["HOME"],"Dropbox/mobility/output/model",p)
	else
		warn("no dropbox on this system")
	end
	return (indir,outdir)
end

function setupMC(autoload::Bool)
	indir, outdir = setPaths()

	if autoload
		# load model-generated data
		moms = readtable(joinpath(indir,"MCtrue.csv"))
	else
		# make model-generated data
		p = Param(2)
		m = Model(p)
	    solve!(m,p)
		s   = simulate(m,p)
		x=computeMoments(s,p,m)

		mom = DataFrame(read_rda(joinpath(indir,"moments.rda"))["m"])
		moms = join(mom,x,on=:moment)
		delete!(moms,[:data_value,:data_sd])
		names!(moms,[:moment,:data_value,:data_sd])

		writetable(joinpath(indir,"MCtrue.csv"),moms)
	end
	return moms
end


#' computes flow statistics of 
#' baseline model. 
#' 1. whats population growth by year in each region
#' 2. what are the in and outflows relative to different populations.
function getFlowStats(dfs::Dict{ASCIIString,DataFrame},pth="null")

	# s is a simulation output
	d = Dict()


	if pth != "null"
		indir, outdir = mig.setPaths()
		fi = readdir(outdir)
		if !in(pth,fi)
			mkpath(string(joinpath(outdir,pth)))
		end
		opth = string(joinpath(outdir,pth))
	end

	for (k,v) in dfs
		v = v[!isna(v[:cohort]),:]
		d[k] = Dict()

		for j in 1:9 

			# population of j over time
			a = @> begin
				v
				@where((:year.>1997) & (:j.==j))
				@by(:year, Owners=sum(:own),Renters=sum(!:own),All=length(:own))
				@transform(popgrowth = [diff(:All),0.0]./:All)
			end

			# movers to j over time
			m_in = @> begin
				v
				@where((:year.>1997) & (:j.!=j))
				@by(:year, Total_in=sum(:moveto.==j), Owners_in=sum((:moveto.==j).*(:h.==1)), Renters_in=sum((:moveto.==j).*(:h.==0)))
			end

			# movers from j over time
			m_out = @> begin
				v
				@where((:year.>1997) & (:j.==j))
				@by(:year, Total_out=sum(:move), Owners_out=sum((:move).*(:h.==1)), Renters_out=sum((:move).*(:h.==0)))
			end

			# merge
			ma = join(a,m_in,on=:year)
			ma = join(ma,m_out,on=:year)
			ma = @transform(ma,Total_in_all=:Total_in./:All,Total_out_all=:Total_out./:All,Rent_in_all=:Renters_in./:All,Rent_in_rent=:Renters_in./:Renters,Own_in_all=:Owners_in./:All,Own_in_own=:Owners_in./:Owners,Rent_out_all=:Renters_out./:All,Rent_out_rent=:Renters_out./:Renters,Own_out_all=:Owners_out./:All,Own_out_own=:Owners_out./:Owners)

			d[k][j] = ma

			if pth != "null"
				writetable(joinpath(opth,"$(k)_flows$(j).csv"),ma)
			end

		end
	end

	return d
end


# get flows plot
function FlowsPlot(s::DataFrame)

       flows = map(x-> proportionmap(@where(s,(:year.==x)&(:j.!=:moveto))[:moveto]),1997:2012)

       fmat = zeros(9,length(flows))
       for i in 1:length(flows)
       for (k,v) in flows[i]
       fmat[k,i] = v
       end
       end
       PyPlot.plot(fmat')
       return fmat
   end

	
function growthExample(pcf::Float64, wnc::Float64)

	P1 = 100.0
	P2 = 90.0

	chi = 0.8
	d = Dict()
	d["pcf"] = ["p1" => P1*pcf, "m1" => P1*pcf*chi, "eq1" => P1*pcf*(1-chi), "p2" => P2*pcf, "m2" => P1*pcf*chi, "eq2" => P2*pcf-P1*pcf*chi]
	d["wnc"] = ["p1" => P1*wnc, "m1" => P1*wnc*chi, "eq1" => P1*wnc*(1-chi), "p2" => P2*wnc, "m2" => P1*wnc*chi, "eq2" => P2*wnc-P1*wnc*chi]
	d["pcf"]["deq"] = (d["pcf"]["eq2"] - d["pcf"]["eq1"]) / d["pcf"]["eq1"]
	d["wnc"]["deq"] = (d["wnc"]["eq2"] - d["wnc"]["eq1"]) / d["wnc"]["eq1"]

	(i,o) = setPaths("properties")
	f = open(joinpath(o,"growthEx.json"),"w")
	JSON.print(f,d)
	close(f)

	return d
end
