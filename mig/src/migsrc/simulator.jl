


function drawMarkov(G::Array{Float64,2},init::Array{Float64,1},N::Int,T::Int)

	out = zeros(Int,N,T)
	eps = rand(N,T)

	n = size(G,1)

	if length(init) != n
		error("length(init) must be size(G,1)")
	end

	g = Categorical(init)

	Gs = mapslices(cumsum,G,2)

	z = zeros(n)

	# initiate everybody on a random state
	# drawn from init distribution
	out[:,1] = rand(g,N)

	for i = 1:N
		for t = 2:T

			z = Gs[ out[i,t-1], : ]

			out[i,t] = findfirst(z.>eps[i,t])

		end
	end
	out
end









# simulator

function simulate(m::Model,p::Param)

	T = p.nt-1

	# set random seed
	srand(p.rseed)

	# compute approximating coefficients from
	# *) m.vh
	# *) m.rho
	# *) m.sh
	# *) m.ch
	# at each discrete index (age,is,ij,ij,tau,ih,ihh)
	# 
	# continuous variables are (a,z,y,p). for those compute a constant basis function
	# on nx evaluation points each. get inverse of those and store in ibm dict
	#
	# then for each i in prod(age,is,ij,ij,tau,ih,ihh), there is a different section of the function you want to approximate and therefore a different approximation coefficient vector
	# for any function f you want to approx:
	# coeff_mat_f = zeros(n_cont_coefs,n_discrete_states)
	# for i in discrete_states
	# 	  ftemp = get_cont_vals(f,i)
	#     coeff_mat_f[:,i] = getTensorCoef(ibm,ftemp)
	# end
	#
	# setup FXpaceXD objects:
	# fx_sh
	# fx_ch
	# fx_vh
	# fx_rho

	# TODO this function is much too slow.
	# this basically puts the continuous approximation of (y,p,z,a) to death. for now at least.
	# way out: also approximate age dimension
	# fx = setupFSpaceXD(m::Model)

	# collect in FX = FSpaceXD_collection([fx_sh,fx_ch,fx_vh,fx_rho])
	# in simulation
	# =============
	#
	# you enter the period on state idx in {age,is,ij,ij,tau,ih,ihh}
	# for each cont fuction f_j there is an FspaceXD object
	# this contains the coeff_mat_f_j and the 4 univariate spline objects
	
	# 2 methods
	# 1. setindex(fx::FSpaceXD,idx::Int) set the current index
	# 2. getValue(point, fx::FSpaceXD). computes each individual basis_function[i] at point[i], using the corresponding coefficient vector coeff_mat_f[:,idx]
	# and then puts it into evalTensor4 to obtain the function value.

	# grids
	agrid = m.grids["assets"]
	ygrid = m.gridsXD["y"]
	pgrid = m.gridsXD["p"]
	zgrid = m.gridsXD["z"]
	ypidx = Gyp_indices(p)  # array with cols iy,ip,idx

	# drawing the shocks 
	# ==================

	# initial distributions
	# TODO
	# all of those should be non-uniform probably
	G0tau = Categorical([1-p.taudist, p.taudist])	# type distribution
	G0z   = Categorical([1/p.nz for i=1:p.nz])
	G0yp   = Categorical([1/(p.ny*p.np) for i=1:(p.ny*p.np)])
	# G0p   = Categorical([1/p.np for i=1:p.np])
	# G0P   = Categorical([1/p.nP for i=1:p.nP])
	x     = [1/i^2 for i=1:length(m.aone:p.na)]
	x     = x / sum(x)
	G0a   = Categorical(x)
	G0j   = Categorical(array(m.regnames[:prop]))	# TODO popdist
	G0k   = Categorical([0.6,0.4])  # 40% of 21-year olds have kids in SIPP

	# prepare cumsum of probability matrices
	# cumrho = cumsum(m.rho,1)	# get cumulative prob of moving along dim k
	# cumGP  = cumsum(m.grids2D["GP"],2)	# transition matrices cumulate over dim 2
	# cumGp  = cumsum(m.gridsXD["Gy"],2)
	# cumGy  = cumsum(m.gridsXD["Gp"],2)
	cumGz  = cumsum(m.gridsXD["Gz"],2)
	cumGyp  = cumsum(m.gridsXD["Gyp"],2)
	# cumGzM = cumsum(m.gridsXD["GzM"],2)
	cumGs  = cumsum(m.gridsXD["Gs"],2)

	# storage
	Dt      = zeros(Int,p.nsim*(T))	# age
	Di      = zeros(Int,p.nsim*(T))	# identity
	Dv      = zeros(p.nsim*(T))	# value
	Dc      = zeros(p.nsim*(T))	# consu
	Dcash   = zeros(p.nsim*(T))	# consu
	Da      = zeros(p.nsim*(T))	# asset value
	Dy      = zeros(p.nsim*(T))	# region y value
	Dincome = zeros(p.nsim*(T))	# income value
	Dp      = zeros(p.nsim*(T))	# house price value
	Dj      = zeros(Int,p.nsim*(T))	# location index
	Dh      = zeros(Int,p.nsim*(T))	# housing state
	Dhh     = zeros(Int,p.nsim*(T))	# housing choice
	Diyp    = zeros(Int,p.nsim*(T))	# region yp joint index
	Dip     = zeros(Int,p.nsim*(T))	# region p index
	Diy     = zeros(Int,p.nsim*(T))	# region y index
	DS      = zeros(p.nsim*(T))	# savings values
	Diz     = zeros(Int,p.nsim*(T))	# z index
	DM      = zeros(Int,p.nsim*(T))	# move
	DMt     = zeros(Int,p.nsim*(T))	# move
	Dkids   = zeros(Int,p.nsim*(T))	# kids yes/no
	Ddist   = zeros(p.nsim*(T))
	Dtau    = zeros(Int,p.nsim*(T))
	Dcanbuy   = zeros(Int,p.nsim*(T))

	ktmp = zeros(Float64,p.nJ)
	ktmp_test = zeros(Float64,p.nJ)
	ktmp2 = zeros(p.nJ)

	avec = zeros(p.na)
	avec2= zeros(p.na)
	fvec = falses(p.na)
	fvec2= falses(p.na)
	fvecs = (falses(p.na),falses(p.na))
	asum = 0.0

	v1tmp = 0.0
	v2tmp = 0.0

	ss = 0.0
	yy = 0.0





	# begin simulation loop
	# =====================

	# @inbounds begin
	for i = 1:p.nsim

		is   = rand(G0k)
		iyp  = rand(G0yp)
		iy   = ypidx[iyp,1]
		ip   = ypidx[iyp,2]
		# iz   = rand(G0z)
		iz   = convert(Int,floor(median([1:p.nz])))	#everybody gets median income
		# ia   = rand(G0a) + m.aone - 1
		# a   =  rand()
		a   =  0.0
		ih   = 0
		itau = rand(G0tau)
		ij   = rand(G0j)


		# tmp vars
		move = false	# move indidicator
		moveto = 0
	
		for age = 1:T

			# point = [a,y,p,z]

			# record beginning of period state
			# --------------------------------

			yy = zgrid[ iz,iy,age,ij ]

			# flag for downpayment constraint
			canbuy = a + yy > p.chi * m.gridsXD["p"][ip,ij]

			Dj[age + T*(i-1)]      = ij
			Dt[age + T*(i-1)]      = age
			Dtau[age + T*(i-1)]    = itau
			Di[age + T*(i-1)]      = i
			Dh[age + T*(i-1)]      = ih
			Da[age + T*(i-1)]      = a
			Dy[age + T*(i-1)]      = ygrid[iy,ij]	
			Dp[age + T*(i-1)]      = pgrid[ip,ij]
			Dincome[age + T*(i-1)] = yy
			Diz[age + T*(i-1)]     = iz
			Diyp[age + T*(i-1)]    = iyp
			Dip[age + T*(i-1)]     = ip
			Diy[age + T*(i-1)]     = iy
			Dkids[age + T*(i-1)]   = is-1
			Dcanbuy[age + T*(i-1)] = canbuy


			# get value for each location
			for ik in 1:p.nJ

				# interpolate rho function in asset dim
				for iia in 1:p.na
					avec[iia] = m.rho[idx10(ik,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
				end

				# there is an approximation issue here:
				# sometimes the approximated vector of probabilities does not sum to 1
				# this happens because rho is poorly approximated
				# I know that the true rho (on the grid) does sum to 1
				# workaround: if I find a vector whose sum deviates significantly from one
				# i just rescale it, assuming that the relative weights are in line with rho
			
				# evaluate at "a"
				# debug code
				# -----------
				# at grid point closest to a
				# imya = find(abs(m.grids["assets"] .- a) .== minabs(m.grids["assets"] .- a))[1]
				# mya = m.grids["assets"][imya]
				# ktmp[ik] = m.rho[idx10(ik,is,iy,ip,iz,imya,ih+1,itau,ij,age,p)]

				# approximate rho at "a" off grid

				# setindex!(fx["rho"],idx)	# set discrete choice ind on rho
				# ktmp[ik] = getValue(point,fx["rho"])

				ktmp[ik] = linearapprox(agrid,avec,a,1,p.na)[1]
			end

			# check quality of approximation off grid
			# ---------------------------

			# if abs(sum(ktmp_test) - 1.0) > 0.001
			# 	println("--------------------------------------")
			# 	println("sum(ktmp_off_grid) = $(sum(ktmp_test))")
			# 	println("ktmp_off_grid/sum(ktmp_off_grid) = $(ktmp_test/sum(ktmp_test))")
			# 	println("sum(ktmp_test/sum(ktmp_test)) = $(sum(ktmp_test/sum(ktmp_test)))")
			# 	println("----------------------------------------------------------------")
			# end------------

			# normalizing vector of moving probs
			if abs(sum(ktmp) - 1.0) > 0.001
				ktmp = ktmp ./ sum(ktmp)
			end
			
			# get cumulative prob
			cumsum!(ktmp2,ktmp,1)
			# throw a k-dice 
			moveto = searchsortedfirst(ktmp2,rand())
			move = ij != moveto

			# debugging
			# if moveto < 1 || moveto > p.nJ
			# 	println("ik=$moveto,iy=$iy,ip=$ip,iz=$iz,ih=$ih,ihh=$ihh,itau=$itau,ij=$ij,age=$age,id=$i,move=$move")
			# 	println("id = $i")
			# 	println("a = $a")
			# 	println("mya = $mya")
			# 	println("ij= $ij")
			# 	println("itau= $itau")
			# 	println(ktmp)
			# 	println(ktmp2)
			# 	println(m.rho[:,is,iy,ip,iz,imya,ih+1,itau,ij,age][:])
			# 	println(size(m.rho[:,is,iy,ip,iz,:,ih+1,itau,ij,age]))
			# 	println(reshape(m.rho[:,is,iy,ip,iz,:,ih+1,itau,ij,age],p.nJ,p.na))
			# 	for iage in 1:age
			# 		println(Da[iage + T*(i-1)])
			# 	end
			# end

			if move

				ihh = 0
				for iia in 1:p.na
					avec[iia] = m.vh[idx11(1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]

					# note: i have an additional feasibility flag stored in vfeas.
					# this basically forces an approximation to return myNA if any of the two
					# interpolating points are myNA (and not just their average!)
					# this was necessary for some approximations.
					# turned off now
					# fvec[iia] = m.vfeas[idx11(1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
				end

				# setindex!(fx["vh"],idx)
				# val = getValue(point,fx["vh"])
				# ss  = getValue(point,fx["sh"])
				# cons = getValue(point,fx["ch"])

				# val = linearapprox(agrid,avec,a,fvec,p)[1]
				val = linearapprox(agrid,avec,a,p)[1]
				# find consumption and savings
				for iia in 1:p.na
					avec[iia]  = m.sh[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
					avec2[iia] = m.ch[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
				end

				# setindex!(ss_fx,idx)
				# ss = getValue([a,y,p,z],ss_fx)
				# no way to exclude infeasible values though!

				# ss                   = linearapprox(agrid,avec,a,fvec,p)[1] 
				# Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,fvec,p)[1]
				ss                   = linearapprox(agrid,avec,a,p)[1] 
				Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,p)[1]
			
			else # stay

				# you are current owner or you can buy
				if (ih==1 || (ih==0 && canbuy))

					# find housing choice
					for iia in 1:p.na
						avec[iia]  = m.vh[idx11(1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						avec2[iia] = m.vh[idx11(2,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						# fvec[iia]  = m.vfeas[idx11(1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						# fvec2[iia] = m.vfeas[idx11(2,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
					end
					# if either of a[low] and a[high] are NA, approximation must return NA
					# v1tmp = linearapprox(agrid,avec,a,fvec,p)[1]
					# v2tmp = linearapprox(agrid,avec2,a,fvec2,p)[1]
					v1tmp = linearapprox(agrid,avec,a,p)[1]
					v2tmp = linearapprox(agrid,avec2,a,p)[1]
					ihh = v1tmp > v2tmp ? 0 : 1
					val = v1tmp > v2tmp ? v1tmp : v2tmp
					# find consumption and savings
					for iia in 1:p.na
						avec[iia]  = m.sh[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						avec2[iia] = m.ch[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
					end

					# fvecs = (fvec,fvec2)

					# ss                   = linearapprox(agrid,avec,a,fvecs[ihh+1],p)[1] 	
					# Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,fvecs[ihh+1],p)[1]
					ss                   = linearapprox(agrid,avec,a,p)[1] 	
					Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,p)[1]
					

				# current renter who cannot buy
				else
					ihh = 0
					for iia in 1:p.na
						avec[iia]  = m.vh   [idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						# fvec[iia]  = m.vfeas[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
					end
					val = linearapprox(agrid,avec,a,fvec,p)[1]
					# find consumption and savings
					for iia in 1:p.na
						avec[iia]  = m.sh[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
						avec2[iia] = m.ch[idx11(ihh+1,moveto,is,iz,iy,ip,iia,ih+1,itau,ij,age,p)]
					end

					# ss                   = linearapprox(agrid,avec, a,fvec,p)[1] 	
					# Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,fvec,p)[1]
					ss                   = linearapprox(agrid,avec, a,p)[1] 	
					Dc[age + T*(i-1)]    = linearapprox(agrid,avec2,a,p)[1]
				
				end
			end

			# record current choices
			# ----------------------

			DS[age + T*(i-1)]    = ss
			Dcash[age + T*(i-1)] = cashFunction(a,yy,ih,ihh,m.gridsXD["p"][ip,moveto],move,moveto,p)

			Dv[age + T*(i-1)]      = val
			Ddist[age + T*(i-1)]   = m.distance[ij,moveto]
			
			DM[age + T*(i-1)]  = move
			DMt[age + T*(i-1)] = moveto
			Dhh[age + T*(i-1)] = ihh	


			# transition to new state
			# -----------------------

			a  = ss
			ij = moveto
			ih = ihh

			# draw new values for z,y and p

			iyp = searchsortedfirst( cumGyp[iy + p.np * (ip-1),:,moveto][:], rand())
			iz  = searchsortedfirst( cumGz[iz,:,moveto][:], rand() )
			is  = searchsortedfirst( cumGs[is,:,age][:], rand() )

			iy   = ypidx[iyp,1]
			ip   = ypidx[iyp,2]

		end	# age t

	end	# individual i

	# end # inbounds

	# collect all data into a dataframe
	w = (Dp .* Dh) .+ Da

	df = DataFrame(id=Di,age=Dt,age2=Dt.^2,kids=PooledDataArray(convert(Array{Bool,1},Dkids)),j=Dj,a=Da,save=DS,c=Dc,cash=Dcash,iz=Diz,ip=Dip,iy=Diy,p=Dp,y=Dy,income=Dincome,move=DM,moveto=DMt,h=Dh,hh=Dhh,v=Dv,wealth=w,km_distance=Ddist,km_distance2=Ddist.^2,own=PooledDataArray(convert(Array{Bool,1},Dh)),canbuy=Dcanbuy)
	df = join(df,m.regnames,on=:j)
	sort!(df,cols=[1,2]	)

	return df
end







	
	
	








# computing moments from simulation
function computeMoments(df::DataFrame,p::Param,m::Model)

	# create a dataframe to push moments on to
	mom1 = DataFrame(moment="", model_value = 0.0, model_sd = 0.0)

	# grouped dfs
	g_div = groupby(df, :Division)
	g_kids = groupby(df, :kids)
	g_own = groupby(df, :h)

	# linear probability model of homeownership
	# =========================================

	if mean(df[:h]) == 1.0 || sum(df[:h]) == 0.0
		nm_h  = ["lm_h_(Intercept)","lm_h_age","lm_h_age2"]  
		coef_h = DataArray(Float64,3)
		std_h =  DataArray(Float64,3)
	else
		lm_h = fit(LinearModel, h ~ age + age2 ,df)
		cc_h  = coeftable(lm_h)
		nm_h  = ASCIIString["lm_h_" *  convert(ASCIIString,cc_h.rownms[i]) for i=1:size(cc_h.mat,1)] 
		coef_h = coef(lm_h)
		std_h = stderr(lm_h)
	end


	# own ~ Division
	for div in g_div
		push!(mom1,["mean_own_$(div[1,:Division])",mean(div[:h]),std(div[:h])])
	end

	# own ~ kids
	for div in g_kids
		kk = "$(div[1,:kids])"
		push!(mom1,["mean_own_kids$(uppercase(kk))",mean(div[:h]),std(div[:h])])
	end
	# TODO std error
	push!(mom1,["cov_own_kids",cov(df[:h],df[:kids]),0.0])


	# linear probability model of mobility
	# ====================================

	lm_mv = fit(LinearModel, move ~ age + age2 ,df)
	cc_mv = coeftable(lm_mv)
	nm_mv = ASCIIString["lm_mv_" * convert(ASCIIString,cc_mv.rownms[i]) for i=1:size(cc_mv.mat,1)] 
	coef_mv = coef(lm_mv)
	std_mv = stderr(lm_mv)

	# move count
	# ----------

	movecount=by(df,:id,x -> sum(x[:move]))
	moved0 = mean(movecount[:x1].==0)
	moved1 = mean(movecount[:x1].==1)
	moved2 = mean(movecount[:x1].==2)

	# TODO std error
	push!(mom1,["moved0",moved0,0.0])
	push!(mom1,["moved1",moved1,0.0])
	push!(mom1,["moved2",moved2,0.0])


	# move ~ own
	# ----------

	for idf in g_own
		kk = "$(idf[1,:own])"
		push!(mom1,["mean_move_own$(uppercase(kk))",mean(idf[:move]),std(idf[:move])])
	end
	# TODO std error
	push!(mom1,["cov_move_h",cov(df[:h],df[:move]),0.0])


	# move ~ kids
	# ----------

	for idf in g_kids
		kk = "$(idf[1,:kids])"
		push!(mom1,["mean_move_kids$(uppercase(kk))",mean(idf[:move]),std(idf[:move])])
	end
	# TODO std error
	push!(mom1,["cov_move_kids",cov(df[:move],df[:kids]),0.0])


	# linear regression of total wealth
	# =================================

	if sum(df[:own]) == 1.0 || sum(df[:own]) == 0.0
		nm_w  = ["lm_w_(Intercept)","lm_w_age","lm_w_age2","lm_w_owntrue"]  
		coef_w = DataArray(Float64,4)
		std_w =  DataArray(Float64,4)
	else
		lm_w = fit(LinearModel, wealth ~ age + age2 + own,df )
		cc_w  = coeftable(lm_w)
		nm_w  = ASCIIString["lm_w_" *  convert(ASCIIString,cc_w.rownms[i]) for i=1:size(cc_w.mat,1)] 
		coef_w = coef(lm_w)
		std_w = stderr(lm_w)
	end

	# wealth ~ division
	# -----------------

	for idf in g_div
		push!(mom1,["mean_wealth_$(idf[1,:Division])",mean(idf[:wealth]),std(idf[:wealth])])
	end



	# collect estimates
	# =================


	nms = vcat(nm_mv,nm_h,nm_w)

	# get rid of parens and hyphens
	# TODO get R to export consitent names with julia output - i'm doing this side here often, not the other one
	for i in 1:length(nms)
		ss = replace(nms[i]," - ","")
		ss = replace(ss,")","")
		ss = replace(ss,"(","")
		# ss = replace(ss,"kidstrue","kidsTRUE")
		ss = replace(ss,"owntrue","ownTRUE")
		nms[i] = ss
	end

	mom2 = DataFrame(moment = nms, model_value = [coef_mv,coef_h,coef_w], model_sd = [std_mv,std_h,std_w])

	dfout = rbind(mom1,mom2)

	return dfout
end







# setting up the FSpace objects for simulation
if Sys.OS_NAME == :Darwin 
	using BSplines
end
function setupFSpaceXD(m::Model,p::Param)

	ndims = 4 # number of cont dimensions

	# ordering of continuous dims
	# 1) a
	# 2) y
	# 3) p
	# 4) z

	# the return object: a dict of collections of fspaces.
	fx = Dict{ASCIIString,Dict{Integer,FSpaceXD}}()
	fx["rho"] = Dict{Integer,FSpaceXD}()
	fx["vh"]  = Dict{Integer,FSpaceXD}()
	fx["ch"]  = Dict{Integer,FSpaceXD}()
	fx["sh"]  = Dict{Integer,FSpaceXD}()

	points = Dict{Int,Dict{Integer,Array}}()
	bounds = Dict{Int,Dict{Integer,Array}}()
	bsp = Dict{Int,Dict{Integer,BSpline}}()

	# full basis to compute inverses
	d = Dict{Int,Dict{Integer,Matrix}}()
	id = Dict{Int,Dict{Integer,Array{Float64,2}}}()
	# bsp[5] = BSpline(m.nknots["age"],m.degs["age"],bounds[5][1],bounds[5][2])

	for ij   = 1:p.nJ	

		points[ij] = Dict{Integer,Array}()
		bounds[ij] = Dict{Integer,Array}()
		bsp[ij] = Dict{Integer,BSpline}()

		# full basis to compute inverses
		d[ij] = Dict{Integer,Matrix}()
		id[ij] = Dict{Integer,Array{Float64,2}}()

		points[ij][1] = m.grids["assets"]
		bounds[ij][1] = [m.grids["assets"][1],m.grids["assets"][end]]
		# points[5] = linspace(1.0,p.nt-1,p.nt-1)
		# bounds[5] = [1.0,convert(Float64,p.nt-1)]

		# construct asset basis with custom knots
		# bsp[1] = BSpline(m.knots["assets"],m.degs["assets"])
		bsp[ij][1] = BSpline(m.nknots["assets"],m.degs["assets"],bounds[ij][1][1],bounds[ij][1][2])
		points[ij][2] = m.gridsXD["y"][:,ij]
		points[ij][3] = m.gridsXD["p"][:,ij]
		points[ij][4] = m.gridsXD["zsupp"][:,ij]

		bounds[ij][2] = [ points[ij][2][1],points[ij][2][end] ]
		bounds[ij][3] = [ points[ij][3][1],points[ij][3][end] ]
		bounds[ij][4] = [ points[ij][4][1],points[ij][4][end] ]

		bsp[ij][2] = BSpline(m.nknots["y"],m.degs["y"],bounds[ij][2][1],bounds[ij][2][2])
		bsp[ij][3] = BSpline(m.nknots["p"],m.degs["p"],bounds[ij][3][1],bounds[ij][3][2])
		bsp[ij][4] = BSpline(m.nknots["z"],m.degs["z"],bounds[ij][4][1],bounds[ij][4][2])


		# get full basis for inverses
		for i=1:ndims
			d[ij][i] = full(getBasis(points[ij][i],bsp[ij][i]))
		end
		for k in collect(keys(d[ij]))
			id[ij][k] = inv(d[ij][k])
		end


		for itau = 1:p.ntau		
		for ih   = 1:2
		for is   = 1:p.ns
		for ik   = 1:p.nJ
		for age  = 1:p.nt-1

			# get FSpace for rho
			# ------------------

			rhotmp = get_cont_vals(ik,is,ih,itau,ij,age,m.rho,p)
			mycoef1 = getTensorCoef(id[ij],rhotmp)
			rhoidx = fx_idx_rho(ik,is,ih,itau,ij,age,p)
			# info("at index $rhoidx")
			fx["rho"][rhoidx] = FSpaceXD(ndims,mycoef1,bsp[ij])


			for ihh  = 1:2


				# get FSpace for vh, ch and sh
				# ----------------------------

				# vh
				vtmp = get_cont_vals(ihh,ik,is,ih,itau,ij,age,m.vh,p)
				mycoef = getTensorCoef(id[ij],vtmp)

				idx = fx_idx(ihh,ik,is,ih,itau,ij,age,p)
				# info("doing state $idx")
				fx["vh"][idx] = FSpaceXD(ndims,mycoef,bsp[ij])

				# ch
				vtmp = get_cont_vals(ihh,ik,is,ih,itau,ij,age,m.ch,p)
				mycoef = getTensorCoef(id[ij],vtmp)

				idx = fx_idx(ihh,ik,is,ih,itau,ij,age,p)
				fx["ch"][idx] = FSpaceXD(ndims,mycoef,bsp[ij])

				# sh                 ihh,ik,is,ih,itau,ij,it,m.vh,p
				vtmp = get_cont_vals(ihh,ik,is,ih,itau,ij,age,m.sh,p)
				mycoef = getTensorCoef(id[ij],vtmp)

				idx = fx_idx(ihh,ik,is,ih,itau,ij,age,p)
				fx["sh"][idx] = FSpaceXD(ndims,mycoef,bsp[ij])

			end

		end
		end
		end
		end
		end

	end

	return fx

end


# FSpace Indexer functions
function fx_idx_rho(ik::Int,is::Int,ih::Int,itau::Int,ij::Int,age::Int,p::Param)
	ik + p.nJ * (is + p.ns * (ih + p.nh * (itau + p.ntau * (ij + p.nJ*(age-1)-1)-1)-1)-1)
end

function fx_idx(ihh::Int,ik::Int,is::Int,ih::Int,itau::Int,ij::Int,age::Int,p::Param)
	 
	ihh + p.nh * (ik + p.nJ * (is + p.ns * (ih + p.nh * (itau + p.ntau * (ij + p.nJ*(age-1)-1)-1)-1)-1)-1)
end

function fx_idx_cont(ia::Int,iy::Int,ip::Int,iz::Int,p::Param)
	ia + p.na * (iy + p.ny * (ip + p.np * (iz-1) -1) -1)
end



# get values in continuous dims at given discrete state
# method for idx11
function get_cont_vals(ihh::Int,ik::Int,is::Int,ih::Int,itau::Int,ij::Int,age::Int,v::Array,p::Param)
# function get_cont_vals(ihh::Int,ik::Int,is::Int,ih::Int,itau::Int,ij::Int,v::Array,p::Param)

	# vout = zeros(p.na*p.np*p.ny*p.nz*(p.nt-1))
	vout = zeros(p.na*p.np*p.ny*p.nz)

	for ia = 1:p.na
	for iy = 1:p.ny
	for ip = 1:p.np
	for iz = 1:p.nz
	# for it = 1:p.nt-1

		@inbounds vout[fx_idx_cont(ia,iy,ip,iz,p)] = v[idx11(ihh,ik,is,iz,iy,ip,ia,ih,itau,ij,age,p)]

	# end
	end
	end
	end
	end

	return vout
end


# method for idx10
function get_cont_vals(ik::Int,is::Int,ih::Int,itau::Int,ij::Int,age::Int,v::Array,p::Param)
# function get_cont_vals(ik::Int,is::Int,ih::Int,itau::Int,ij::Int,v::Array,p::Param)

	vout = zeros(p.na*p.np*p.ny*p.nz)

	for ia = 1:p.na
	for iy = 1:p.ny
	for ip = 1:p.np
	for iz = 1:p.nz
	# for it = 1:p.nt-1

		# vout[fx_idx_cont(ia,ip,iy,iz,it,p)] = v[idx10(ik,is,iz,iy,ip,ia,ih,itau,ij,it,p)]
		@inbounds vout[fx_idx_cont(ia,iy,ip,iz,p)] = v[idx10(ik,is,iz,iy,ip,ia,ih,itau,ij,age,p)]

	# end
	end
	end
	end
	end

	return vout
end



















	