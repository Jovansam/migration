

# miscellaneous includes

# objective function to work with mopt
function objfunc(pd::Dict,mom::DataFrame,whichmom::Array{ASCIIString,1})

	# info("start model solution")
	time0 = time()
	p = Param(2)	# create a default param type
	update!(p,pd)	# update with values changed by the optimizer
	m = Model(p)
	mig.solve!(m,p)
	# info("end model solution after $(round(time()-time0)) seconds")

	# info("simulation/computation of moments")
	s   = simulate(m,p)
	mms = computeMoments(s,p,m)	# todo: return DataFrame(moment,model_value)

	println("time till mms = $(time()-time0)")

	mom2 = join(mom,mms,on=:moment)

	fval = sum((mom2[findin(mom2[:moment],whichmom),:data_value] - mom2[findin(mom2[:moment],whichmom),:model_value]).^2)

    mout = transpose(mom2[[:moment,:model_value]],1)

	time1 = round(time()-time0)
	ret = ["value" => fval, "params" => deepcopy(pd), "time" => time1, "status" => 1, "moments" => mout]
	return ret
end

function mywrap()
	p = mig.Param(2)
	m = mig.Model(p)
    mig.solve!(m,p)
end


function runSim()
	p = mig.Param(2)
	m = mig.Model(p)
    mig.solve!(m,p)
	s   = simulate(m,p)
	mms = computeMoments(s,p,m)	# todo: return DataFrame(moment,model_value)
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
# convert(::Type{Array{Int64,1}}, PooledDataArray{Int64,Uint32,1})
mylog(x::Float64) = ccall((:log, "libm"), Float64, (Float64,), x)
myexp(x::Float64) = ccall((:exp, "libm"), Float64, (Float64,), x)
mylog2(x::Float64) = ccall(:log, Cdouble, (Cdouble,), x)
myexp2(x::Float64) = ccall(:exp, Cdouble, (Cdouble,), x)