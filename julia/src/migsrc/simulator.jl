


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

	# grids
	agrid = m.grids["assets"]
	ygrid = m.gridsXD["y"]
	pgrid = m.gridsXD["p"]
	zgrid = m.gridsXD["z"]

	# drawing the shocks 
	# ==================

	# initial distributions
	# TODO
	# all of those should be non-uniform probably
	G0tau = Categorical([1-p.taudist, p.taudist])	# type distribution
	G0z   = Categorical([1/p.nz for i=1:p.nz])
	G0y   = Categorical([1/p.ny for i=1:p.ny])
	G0p   = Categorical([1/p.np for i=1:p.np])
	G0P   = Categorical([1/p.nP for i=1:p.nP])
	x     = [1/i^2 for i=1:length(m.aone:p.na)]
	x     = x / sum(x)
	G0a   = Categorical(x)
	G0j   = Categorical(array(m.regnames[:prop]))	# TODO popdist
	G0k   = Categorical([0.6,0.4])  # 40% of 21-year olds have kids in SIPP

	# prepare cumsum of probability matrices
	# cumrho = cumsum(m.rho,1)	# get cumulative prob of moving along dim k
	cumGP  = cumsum(m.grids2D["GP"],2)	# transition matrices cumulate over dim 2
	cumGp  = cumsum(m.gridsXD["Gy"],2)
	cumGy  = cumsum(m.gridsXD["Gp"],2)
	cumGz  = cumsum(m.gridsXD["Gz"],2)
	# cumGzM = cumsum(m.gridsXD["GzM"],2)
	cumGs  = cumsum(m.gridsXD["Gs"],2)

	# storage
	Dt      = zeros(Int,p.nsim*(T))	# age
	Di      = zeros(Int,p.nsim*(T))	# identity
	Dv      = zeros(p.nsim*(T))	# value
	Dc      = zeros(p.nsim*(T))	# consu
	Da      = zeros(p.nsim*(T))	# asset value
	Dy      = zeros(p.nsim*(T))	# region y value
	Dz      = zeros(p.nsim*(T))	# income shock value
	Dincome = zeros(p.nsim*(T))	# income value
	Dp      = zeros(p.nsim*(T))	# house price value
	Dj      = zeros(Int,p.nsim*(T))	# location index
	Dh      = zeros(Int,p.nsim*(T))	# housing state
	Dhh     = zeros(Int,p.nsim*(T))	# housing choice
	DiP     = zeros(Int,p.nsim*(T))	# macro P index
	Dip     = zeros(Int,p.nsim*(T))	# region p index
	Diy     = zeros(Int,p.nsim*(T))	# region y index
	DiS     = zeros(Int,p.nsim*(T))	# savings index
	DS     = zeros(p.nsim*(T))	# savings values
	Diz     = zeros(Int,p.nsim*(T))	# z index
	DM      = zeros(Int,p.nsim*(T))	# move
	DMt     = zeros(Int,p.nsim*(T))	# move
	Dkids   = zeros(Int,p.nsim*(T))	# kids yes/no
	Ddist   = zeros(p.nsim*(T))
	Dtau    = zeros(Int,p.nsim*(T))

	ktmp = zeros(p.nJ)
	ktmp2 = zeros(p.nJ)

	# begin simulation loop
	# =====================

	# @inbounds begin
	for i = 1:p.nsim

		is   = rand(G0k)
		iy   = rand(G0y)
		ip   = rand(G0p)
		iP   = rand(G0P)
		# iz   = rand(G0z)
		iz   = convert(Int,floor(median([1:p.nz])))	#everybody gets median income
		# ia   = rand(G0a) + m.aone - 1
		ia   =  m.aone 
		ih   = 0
		itau = rand(G0tau)
		ij   = rand(G0j)


		# tmp vars
		move = false	# move indidicator
		moveto = 0
	
		for age = 1:T

			# move to where?
			# get probabilities of moving to k

			# need to 
			for ik in 1:p.nJ
				ktmp[ik] = m.rho[idx11(ik,is,iy,ip,iP,iz,ia,ih+1,itau,ij,age,p)]
			end
			cumsum!(ktmp2,ktmp,1)
			# TODO slow
			moveto = searchsortedfirst(ktmp2,rand())
			move = ij != moveto

			if move
				ihh = 0
			else
				# find housing choice
				ihh = m.dh[idx10(is,iy,ip,iP,iz,ia,ih+1,itau,ij,age,p)]
			end

			# record current period state
			# ---------------------------

			Dj[age + T*(i-1)] = ij
			Dt[age + T*(i-1)] = age
			Dtau[age + T*(i-1)] = itau
			Di[age + T*(i-1)] = i
			Dh[age + T*(i-1)] = ih
			Da[age + T*(i-1)] =	agrid[ ia ]
			Dy[age + T*(i-1)] = ygrid[iy,ij]	# SLOW
			Dz[age + T*(i-1)] = zgrid[iz,ij,age]
			Dp[age + T*(i-1)] = pgrid[iP,ip,ij]
			Dincome[age + T*(i-1)] = income(zgrid[ iz,ij,age ], ygrid[iy,ij])
			Diz[age + T*(i-1)] = iz
			DiP[age + T*(i-1)] = iP
			Dip[age + T*(i-1)] = ip
			Diy[age + T*(i-1)] = iy
			Dv[age + T*(i-1)] = m.v[idx11(moveto,is,iy,ip,iP,iz,ia,ih+1,itau,ij,age,p)]
			Dkids[age + T*(i-1)] = is-1
			Ddist[age + T*(i-1)] = m.distance[ij,moveto]

			# current choices
			# ---------------

			ss = m.s[idx11(moveto,is,iy,ip,iP,iz,ia,ih+1,itau,ij,age,p)]
			
			DM[age + T*(i-1)] = move
			DMt[age + T*(i-1)] = moveto
			Dc[age + T*(i-1)] = m.c[idx11(moveto,is,iy,ip,iP,iz,ia,ih+1,itau,ij,age,p)]
			Dhh[age + T*(i-1)] = ihh	# housign choice

			# transition to new state
			# -----------------------




			# catching simulation errors
			# =========================
			if ss==0
				# println(ktmp)
				ia = 1
				println("id=$i")
				println("next period asset state is zero at\nik=$moveto,iy=$iy,ip=$ip,iP=$iP,iz=$iz,ih=$ih,ihh=$ihh,itau=$itau,ij=$ij,age=$age,id=$i,move=$move")
				println("age=$age")
				println("ia=$ia")
				DiS[age + T*(i-1)]=1
				DS[age + T*(i-1)]=agrid[1]
				# inc = income(m.gridsXD["y"][iy,ij],m.gridsXD["z"][iz,ij,age])
				# cash = cashFunction(Da[age + T*(i-1)],income(m.gridsXD["y"][iy,ij],m.gridsXD["z"][iz,ij,age]),ih,ihh,m.gridsXD["p"][iP,ip,ij],move,moveto,p)
				# println("current value=$(Dv[age + T*(i-1)])")
				# println("current cons=$(Dc[age + T*(i-1)])")
				# println("income = $inc")
				# println("grossA = $(grossSaving(agrid[ia],p))")
				# println("cash = $cash")
				# error("next period asset state is zero at\nik=$moveto,iy=$iy,ip=$ip,iP=$iP,iz=$iz,a=$(agrid[ia]),ih=$ih,ihh=$ihh,itau=$itau,ij=$ij,age=$age,id=$i,move=$move")
			else

				DiS[age + T*(i-1)] = ss
				ia = ss
				DS[age + T*(i-1)] = agrid[ ss ] 

			end
			# =========================



			ij = moveto
			ih = ihh
			# get new shocks in region 
			# you are moving to
			# -----------------------

			# iP = searchsortedfirst( cumGP[iP,:][:] , rand() ) 	# SLOW, all of them
			# ip = searchsortedfirst( cumGp[ip,:,moveto][:], rand() )
			# iy = searchsortedfirst( cumGy[iy,:,moveto][:], rand() )
			# if move
				# iz = searchsortedfirst( cumGzM[iz,:,moveto][:], rand() )
			# else
				# iz = searchsortedfirst( cumGz[iz,:,moveto][:], rand() )
			# end
			# is = searchsortedfirst( cumGs[is,:,age][:], rand() )

		end	# age t

	end	# individual i

	# end # inbounds

	# collect all data into a dataframe
	w = (Dp .* Dh) .+ Da

	df = DataFrame(id=Di,age=Dt,age2=Dt.^2,kids=PooledDataArray(convert(Array{Bool,1},Dkids)),j=Dj,a=Da,saveidx=DiS,save=DS,c=Dc,iz=Diz,ip=Dip,iy=Diy,iP=DiP,p=Dp,y=Dy,income=Dincome,move=DM,moveto=DMt,h=Dh,hh=Dhh,v=Dv,wealth=w,km_distance=Ddist,km_distance2=Ddist.^2,own=PooledDataArray(convert(Array{Bool,1},Dh)))
	df = join(df,m.regnames,on=:j)
	sort!(df,cols=[1,2]	)

	return df
end



# computing moments from simulation
function computeMoments(df::DataFrame,p::Param,m::Model)

	# moved0
	# moved1
	# moved2

	# linear probability model of mobility
	# ====================================
	# move ~ age + age^2 + dist + dist2 + own + kids
	lm_mv = fit(LinearModel, move ~ age + age2 + km_distance + km_distance2 + kids + own,df)


	# linear probability model of homeownership
	# =========================================
	lm_h = fit(LinearModel, h ~ age + age2 + Division + kids,df)


	# linear regression of total wealth
	# =================================
	lm_w = fit(LinearModel, wealth ~ age + age2 + own + Division,df )

	# collect estimates
	# =================
	cc_mv = coeftable(lm_mv)
	cc_h  = coeftable(lm_h)
	cc_w  = coeftable(lm_w)

	nm_mv = ASCIIString["lm_mv_" * convert(ASCIIString,cc_mv.rownms[i]) for i=1:size(cc_mv.mat,1)] 
	nm_h  = ASCIIString["lm_h_" *  convert(ASCIIString,cc_h.rownms[i]) for i=1:size(cc_h.mat,1)] 
	nm_w  = ASCIIString["lm_w_" *  convert(ASCIIString,cc_w.rownms[i]) for i=1:size(cc_w.mat,1)] 

	nms = vcat(nm_mv,nm_h,nm_w)

	# get rid of parens and hyphens
	# TODO get R to export consitent names with julia output - i'm doing this side here often, not the other one
	for i in 1:length(nms)
		ss = replace(nms[i]," - ","")
		ss = replace(ss,")","")
		ss = replace(ss,"(","")
		ss = replace(ss,"kidstrue","kidsTRUE")
		ss = replace(ss,"owntrue","ownTRUE")
		nms[i] = ss
	end


	dfout = DataFrame(moment = nms, model_value = DataArray([coef(lm_mv),coef(lm_h),coef(lm_w)]), model_sd = DataArray([stderr(lm_mv),stderr(lm_h),stderr(lm_w)]))

	return dfout



	# # overall ownership rate
	# own = mean(df[: ,:h])

	# # ownership by age?
	# ownage = by(df, :age, d -> mean(d[:h]))

	# # find all movers, i.e. people who move at least once
	# movers = unique(df[df[:,:move].==true, :id])
	# # fraction of people who never move
	# nomove = 1 - length(movers) / p.nsim

	# # fraction of people who move twice/more
	# x = by(df[df[:move].==true,:], :id, d -> DataFrame(N=size(d,1)))    
	# nummoves = by(x,:N,d -> DataFrame(Num=size(d,1))) 

	# # moving rate by ownership
	# movebyh = DataFrames.by(df, :h, d -> DataFrames.DataFrame(moverate=mean(d[:move])))

	# # moving rate by age
	# movebyage = by(df, :age, d -> DataFrame(moverate=mean(d[:move])))

	# # assets by ownership and age
	# # aggregate in 5-year bins
	
	# # assets_hage = by(df, [:age, :h], d -> DataFrame(assets=mean(d[:,:a])))


	# assets_h = by(df,  :h, d -> DataFrame(assets=mean(d[:a])))
	# assets_age = by(df,  :age, d -> DataFrame(assets=mean(d[:a])))
	# assets_hage = by(df, [ :h, :age] , d -> DataFrame(assets=mean(d[:a])))

	# # # autocorrelation of income by region
	# # # make a lagged income for each id
	# # ly = df[:,[:j, :id ,:age, :y]]
	# # ly = hcat(ly,DataFrame(Ly=@data([0.0 for i in 1:nrow(ly)])))
	# # for i in 1:nrow(ly)
	# # 	if ly[i,:age] == 1 
	# # 		ly[i,:Ly] = NA
	# # 	else
	# # 		ly[i,:Ly] = ly[i-1,:y]
	# # 	end
	# # end

	# # rhos = by( ly[ly[:age].!=1,:], :j, d -> DataFrame(rho = cor(d[:y],d[:Ly])))

	# # equity
	# equity = by(df,:age,d->DataFrame(equity=mean(d[:,:eq])))

	# # fraction of people who move with neg equity

	# out = ["own" => own, "ownage" => ownage, "nomove" => nomove, "nummoves" => nummoves, "movebyh" => movebyh, "movebyage" => movebyage, "assets_h" => assets_h, "assets_age" => assets_age, "assets_hage" => assets_hage,"rhos" => rhos, "equity" => equity]

	# return out

end





























	