


#ifdef RcppCompile
#include "../../cpp/src/CMig6.h"
#else
#include "CMig6.h"		// include class declaration of owner class
#endif

using namespace blitz;
using namespace std;


// test function for list

//Rcpp::List myfun( void ){
	//Rcpp::List mylist = Rcpp::List::create( Rcpp::_["elt1"] = 1 );
	//return mylist;
//}


///////////////////////
// class implementation
// of Migration class
///////////////////////

// default constructor
CMig6::CMig6():

	// this is syntactic sugar. an initialiser list. 

	ResStay(2,2,2,2,2,2,2,FortranArray<7>()),
    ResSell(2,2,2,2,2,2,2,FortranArray<7>()),
	ResRent(2,2,2,2,2,2,2,FortranArray<7>()),
    ResBuy( 2,2,2,2,2,2,2,FortranArray<7>()),

    v_loc_stay(2,2,2,2,2,2,FortranArray<6>()),	
    v_loc_sell(2,2,2,2,2,2,FortranArray<6>()),  
    v_loc_rent(2,2,2,2,2,2,FortranArray<6>()),	
    v_loc_buy( 2,2,2,2,2,2,FortranArray<6>()),   
	c_loc_stay(2,2,2,2,2,2,FortranArray<6>()),	
	c_loc_sell(2,2,2,2,2,2,FortranArray<6>()),  
	c_loc_rent(2,2,2,2,2,2,FortranArray<6>()),	
	c_loc_buy( 2,2,2,2,2,2,FortranArray<6>()),   
	s_loc_stay(2,2,2,2,2,2,FortranArray<6>()),  
	s_loc_sell(2,2,2,2,2,2,FortranArray<6>()), 
	s_loc_rent(2,2,2,2,2,2,FortranArray<6>()), 
	s_loc_buy( 2,2,2,2,2,2,FortranArray<6>()), 
	ctmp(      2,2,2,2,2,2,FortranArray<6>()),  	
	xtmp(      2,2,2,2,2,2,FortranArray<6>()),  	

	move_stay(2,2,2,2,2,FortranArray<5>()),
	move_sell(2,2,2,2,2,FortranArray<5>()),
	move_rent(2,2,2,2,2,FortranArray<5>()),
	move_buy( 2,2,2,2,2,FortranArray<5>()),

	Vown(  2,2,2,2,2,FortranArray<5>()),	
	Vrent( 2,2,2,2,2,FortranArray<5>()),	
	EVown( 2,2,2,2,2,FortranArray<5>()),	
	EVrent(2,2,2,2,2,FortranArray<5>()),	
	v_loc_tmp(2,2,2,2,2,FortranArray<5>()),	
	v_stay(2,2,2,2,2,FortranArray<5>()),	
	v_sell(2,2,2,2,2,FortranArray<5>()),	
	v_rent(2,2,2,2,2,FortranArray<5>()),	
	v_buy(2,2,2,2,2,FortranArray<5>()),	

	Down(  2,2,2,2,2,FortranArray<5>()),  
	Drent( 2,2,2,2,2,FortranArray<5>()),  
	
	vplustmp(2,2,2,2,FortranArray<4>()), 
    dim_ayp_here_there_t(2,2,2,2,2,2) ,				   
    dim_ayp_here_there(2,2,2,2,2) ,				   
    dim_ayp_here_t(2,2,2,2,2) ,				   
    dim_ayp_here_y(2,2,2,2,2) ,				   
    dim_ayp_here(2,2,2,2) ,				   
    dim_ayp(2,2,2), 
	name("CMig6"),	
	G(2,2,FortranArray<2>()) ,
	MoveCost(2,2,FortranArray<2>()) ,
	Amenity(2,FortranArray<1>()) {
		ResStay    = 0.1;
		ResSell    = 0.2;
		ResRent    = 0.3;
		ResBuy     = 0.4;
		v_loc_stay = 1;
		v_loc_sell = 2;
		v_loc_rent = 3;
		v_loc_buy  = 4;
		s_loc_stay = 1;
		s_loc_sell = 2;
		s_loc_rent = 3;
		s_loc_buy  = 4;
		move_stay = 0;
		move_sell = 0;
		move_rent = 0;
		move_buy  = 0;
	    G          = 0.9,0.3,0.1,0.7;
	    MoveCost   = 0,1,1,0;
	    Amenity    = 1,2;
		p.myNA     = -99;
		p.beta     = 0.9;
}

// constructor 2: data referenced 
CMig6::CMig6(TinyVector<int,7> D_ayp_here_there_ta,		
	         TinyVector<int,6> D_ayp_here_there_t,   
	         TinyVector<int,6> D_ayp_here_there_a,   
	         TinyVector<int,5> D_ayp_here_there,   
	   	     TinyVector<int,5> D_ayp_here_t,      
	   	     TinyVector<int,5> D_ayp_here_y,      
	   	     TinyVector<int,4> D_ayp_here,      
	   	     TinyVector<int,3> D_ayp,               
	   	     TinyVector<int,2> D_y,                 
	   	     Parstruc* pars ,                       
	   	     Array<double,7> data_stay,             
	   	     Array<double,7> data_sell,             
	   	     Array<double,7> data_rent,             
	   	     Array<double,7> data_buy,              
	   	     Array<double,2> data_G	 ,              
	   	     Array<double,2> data_MoveC	,              
	   	     Array<double,1> data_Amenity)  :              
	   	  
	// this is syntactic sugar. an initialiser list. 

	ResStay(D_ayp_here_there_ta,FortranArray<7>()),
	ResSell(D_ayp_here_there_ta,FortranArray<7>()),
	ResRent(D_ayp_here_there_ta,FortranArray<7>()),
	ResBuy( D_ayp_here_there_ta,FortranArray<7>()),

    v_loc_stay(D_ayp_here_there_t,FortranArray<6>()),	
    v_loc_sell(D_ayp_here_there_t,FortranArray<6>()),  
    v_loc_rent(D_ayp_here_there_t,FortranArray<6>()),	
    v_loc_buy( D_ayp_here_there_t,FortranArray<6>()),   
	c_loc_stay(D_ayp_here_there_t,FortranArray<6>()),	
	c_loc_sell(D_ayp_here_there_t,FortranArray<6>()),  
	c_loc_rent(D_ayp_here_there_t,FortranArray<6>()),	
	c_loc_buy( D_ayp_here_there_t,FortranArray<6>()),   
	s_loc_stay(D_ayp_here_there_t,FortranArray<6>()),  
	s_loc_sell(D_ayp_here_there_t,FortranArray<6>()), 
	s_loc_rent(D_ayp_here_there_t,FortranArray<6>()), 
	s_loc_buy( D_ayp_here_there_t,FortranArray<6>()), 
	ctmp(      D_ayp_here_there_a,FortranArray<6>()),  	
	xtmp(      D_ayp_here_there_a,FortranArray<6>()),  	

	move_stay(D_ayp_here_t,FortranArray<5>()),
	move_sell(D_ayp_here_t,FortranArray<5>()),
	move_rent(D_ayp_here_t,FortranArray<5>()),
	move_buy( D_ayp_here_t,FortranArray<5>()),

	Vown(  D_ayp_here_t,FortranArray<5>()),	
	Vrent( D_ayp_here_t,FortranArray<5>()),	
	EVown( D_ayp_here_t,FortranArray<5>()),	
	EVrent(D_ayp_here_t,FortranArray<5>()),	
	v_stay(D_ayp_here_t,FortranArray<5>()),	
	v_sell(D_ayp_here_t,FortranArray<5>()),	
	v_rent(D_ayp_here_t,FortranArray<5>()),	
	v_buy(D_ayp_here_t,FortranArray<5>()),	
	v_loc_tmp(D_ayp_here_there,FortranArray<5>()),	

	Down(  D_ayp_here_t,FortranArray<5>()),  
	Drent( D_ayp_here_t,FortranArray<5>()),  
	
	vplustmp(D_ayp_here,FortranArray<4>()), 
    dim_ayp_here_there_t(D_ayp_here_there_t) ,				   
	dim_ayp_here_there(D_ayp_here_there) ,				   
    dim_ayp_here_t(D_ayp_here_t) ,				   
    dim_ayp_here_y(D_ayp_here_y) ,				   
    dim_ayp_here(D_ayp_here) ,				   
    dim_ayp(D_ayp), 
	name("CMig6"),	
	G(D_y,FortranArray<2>()) ,
	MoveCost(D_ayp_here(3),D_ayp_here(3),FortranArray<2>()) ,
	Amenity(D_ayp_here(3),FortranArray<1>()) ,
	p(*pars) {						  
		// reference the data
		ResStay.reference(data_stay);
		ResSell.reference(data_sell);
		ResRent.reference(data_rent);
		ResBuy.reference(data_buy );
		G.reference(data_G);
		MoveCost.reference(data_MoveC);
		Amenity.reference(data_Amenity);
		Vown = 0;
		Vrent = 0;
		Down = 0;
		Drent = 0;
		v_stay = 1;
		v_sell = 2;
		v_rent = 3;
		v_buy  = 4;
		v_loc_stay = 1;
		v_loc_sell = 2;
		v_loc_rent = 3;
		v_loc_buy  = 4;
		s_loc_stay = 1;
		s_loc_sell = 2;
		s_loc_rent = 3;
		s_loc_buy  = 4;
		move_stay = 0;
		move_sell = 0;
		move_rent = 0;
		move_buy  = 0;
}



// Define Getters




#ifdef RcppCompile   // conditions for printing the show method: if you are working from R, print with Rcpp::Rcout

// Define show method
// TODO ask how to compile with R libraries
void CMig6::show(){
	int ma = 10;
	int my = 10;
	ma = min(ma,dim_ayp_here_t(0));
	my = min(my,dim_ayp_here_t(1));

	Rcpp::Rcout << "CMig6 show() method: " << endl;
	Rcpp::Rcout << "we have this dimension vector: " << endl;
	Rcpp::Rcout <<  dim_ayp_here_t << endl;
	Rcpp::Rcout << "we have beta: " << endl;
	Rcpp::Rcout <<  p.beta << endl;
	Rcpp::Rcout << "we have myNA: " << endl;
	Rcpp::Rcout <<  p.myNA << endl;
	Rcpp::Rcout << "we have G: " << endl;
	Rcpp::Rcout <<  G << endl;
	Rcpp::Rcout << "showing the first " << ma << " rows" << endl;
	Rcpp::Rcout << "=======================" << endl;
	Rcpp::Rcout <<  endl;
	Rcpp::Rcout << "ResStay(:,:,1,1,1,nT,nA) = " << endl;
	Rcpp::Rcout << ResStay(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	Rcpp::Rcout << "ResSell(:,:,1,1,1,nT,nA) = " << endl;
	Rcpp::Rcout << ResSell(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	Rcpp::Rcout << "ResRent(:,:,1,1,1,nT,nA) = " << endl;
	Rcpp::Rcout << ResRent(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	Rcpp::Rcout << "ResBuy(:,:,1,1,1,nT,nA) = " << endl;
	Rcpp::Rcout << ResBuy(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	Rcpp::Rcout << "end of show method: " << endl;
	Rcpp::Rcout << "===================" << endl;
}


#else   // if you are not in R and must print to stdout

// Define show method
void CMig6::show(){
	int ma = 10;
	int my = 10;
	ma = min(ma,dim_ayp_here_t(0));
	my = min(my,dim_ayp_here_t(1));

	cout << "CMig6 show() method: " << endl;
	cout << "we have this dimension vector: " << endl;
	cout <<  dim_ayp_here_t << endl;
	cout << "we have beta: " << endl;
	cout <<  p.beta << endl;
	cout << "we have myNA: " << endl;
	cout <<  p.myNA << endl;
	cout << "we have G: " << endl;
	cout <<  G << endl;
	cout << "showing the first " << ma << " rows" << endl;
	cout << "=======================" << endl;
	cout <<  endl;
	cout << "ResStay(:,:,1,1,1,nT,nA) = " << endl;
	cout << ResStay(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	cout << "ResSell(:,:,1,1,1,nT,nA) = " << endl;
	cout << ResSell(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	cout << "ResRent(:,:,1,1,1,nT,nA) = " << endl;
	cout << ResRent(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	cout << "ResBuy(:,:,1,1,1,nT,nA) = " << endl;
	cout << ResBuy(Range(fromStart,ma),Range(fromStart,my),1,1,1,dim_ayp_here_t(4),dim_ayp_here_t(0)) << endl;
	cout << "end of show method: " << endl;
	cout << "===================" << endl;
}

#endif // printing conditions


//std::vector<double> CMig6::GetResStayNumeric( void ) {
	//Array<double,5>::iterator iter;
	//std::vector<double> out;
	//for (iter = ResStay.begin() ; iter!=ResStay.end();++iter){
		//out.push_back(*iter);
	//}
	//return out;
//}

//std::vector<double> CMig6::GetResSellNumeric( void ) {
	//Array<double,5>::iterator iter;
	//std::vector<double> out;
	//for (iter = ResSell.begin() ; iter!=ResSell.end();++iter){
		//out.push_back(*iter);
	//}
	//return out;
//}

//std::vector<double> CMig6::GetResRentNumeric( void ) {
	//Array<double,5>::iterator iter;
	//std::vector<double> out;
	//for (iter = ResRent.begin() ; iter!=ResRent.end();++iter){
		//out.push_back(*iter);
	//}
	//return out;
//}

//std::vector<double> CMig6::GetResBuyNumeric( void ) {
	//Array<double,5>::iterator iter;
	//std::vector<double> out;
	//for (iter = ResBuy.begin() ; iter!=ResBuy.end();++iter){
		//out.push_back(*iter);
	//}
	//return out;
//}


//// =====================================
//// Computation of period value functions
//// =====================================


void CMig6::ComputeStay(int age) {

	firstIndex   i1;	// a
	secondIndex  i2;    // y
	thirdIndex   i3;	// p
	fourthIndex  i4;	// here
	fifthIndex   i5;	// there
	sixthIndex   i6;	// save

	vplustmp = EVown(Range::all(),Range::all(),Range::all(),Range::all(),age+1);	// EV(a,y,p,here,age)
	// get consumption at all states,savings combinations
	ctmp     = ResStay(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age,Range::all());	// ResStay(a,y,p,here,there,age,saving)
	xtmp     = where(ctmp > 0, p.imgamma*(pow(ctmp(i1,i2,i3,i4,i5,i6),p.mgamma)) + p.theta + p.beta * vplustmp(i6,i2,i3,i5) - MoveCost(i4,i5) + Amenity(i5), p.myNA);	//vplustmp(save,y,p,there)
	// get value of being an owner in all locations (here,there)
	v_loc_stay(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = max(xtmp, i6);
	s_loc_stay(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(xtmp, i6);

	// that would be perfect. unfortunately cannot mix index placeholders with fixed indices (like 'age' here)
	//c_loc_tmp(i1,i2,i3,i4,i5) = ctmp(i1,i2,i3,i4,i5, s_loc_stay(i1,i2,i3,i4,i5,age) );
	//c_loc_stay(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = c_loc_tmp;
	// instead gotta do that:
	FindStayCons( age );	
}

void CMig6::ComputeSell(int age) {

	firstIndex   i1;	// a
	secondIndex  i2;    // y
	thirdIndex   i3;	// p
	fourthIndex  i4;	// here
	fifthIndex   i5;	// there
	sixthIndex   i6;	// save

	vplustmp = EVrent(Range::all(),Range::all(),Range::all(),Range::all(),age+1);	// EV(a,y,p,here,age)
	// get consumption at all states,savings combinations
	ctmp     = ResSell(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age,Range::all());	// ResStay(a,y,p,here,there,age,saving)
	xtmp     = where(ctmp > 0, p.imgamma*(pow(ctmp(i1,i2,i3,i4,i5,i6),p.mgamma)) +    0    + p.beta * vplustmp(i6,i2,i3,i5) - MoveCost(i4,i5) + Amenity(i5), p.myNA);	//vplustmp(save,y,p,there)
	// get value of selling at combo (here,there)
	v_loc_sell(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = max(xtmp, i6);
	s_loc_sell(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(xtmp, i6);
	FindSellCons( age );	

}

void CMig6::ComputeRent(int age) {

	firstIndex   i1;	// a
	secondIndex  i2;    // y
	thirdIndex   i3;	// p
	fourthIndex  i4;	// here
	fifthIndex   i5;	// there
	sixthIndex   i6;	// save

	vplustmp = EVrent(Range::all(),Range::all(),Range::all(),Range::all(),age+1);	// EV(a,y,p,here,age)
	// get consumption at all states,savings combinations
	ctmp     = ResRent(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age,Range::all());
	xtmp     = where(ctmp > 0, p.imgamma*(pow(ctmp(i1,i2,i3,i4,i5,i6),p.mgamma)) +    0    + p.beta * vplustmp(i6,i2,i3,i5) - MoveCost(i4,i5) + Amenity(i5), p.myNA);	//vplustmp(save,y,p,there)
	// get value of staying
	v_loc_rent(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = max(xtmp, i6);
	s_loc_rent(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(xtmp, i6);
	FindRentCons( age );	

}


void CMig6::ComputeBuy(int age) {

	firstIndex   i1;	// a
	secondIndex  i2;    // y
	thirdIndex   i3;	// p
	fourthIndex  i4;	// here
	fifthIndex   i5;	// there
	sixthIndex   i6;	// save

	vplustmp = EVown(Range::all(),Range::all(),Range::all(),Range::all(),age+1);	// EV(a,y,p,here,age)
	// get consumption at all states,savings combinations
	ctmp     = ResBuy(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age,Range::all());
	xtmp     = where(ctmp > 0, p.imgamma*(pow(ctmp(i1,i2,i3,i4,i5,i6),p.mgamma)) + p.theta + p.beta * vplustmp(i6,i2,i3,i5) - MoveCost(i4,i5) + Amenity(i5), p.myNA);	//vplustmp(save,y,p,there)
	// get value of staying
	v_loc_buy(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = max(xtmp, i6);
	s_loc_buy(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(xtmp, i6);
	FindBuyCons( age );	
}



// Consumption finder functions
// ============================

void CMig6::FindStayCons( int age ){
	int idx;
	TinyVector<int,6> ext;
	ext = s_loc_stay.extent() + 1; // add + 1 here because we have fortran arrays, which are indexed 1,2,...,extent(). So the upper bound of the loop must is extent()+1
	for (int i1=1;i1<ext(0);++i1){		// a
		for (int i2=1;i2<ext(1);++i2){	// y
			for (int i3=1; i3<ext(2); ++i3){	//p
				for (int i4=1; i4<ext(3); ++i4){	//here
					for (int i5=1; i5<ext(4); ++i5){	//there

						idx                            = s_loc_stay(i1,i2,i3,i4,i5,age);	// savings choice at that index
						c_loc_stay(i1,i2,i3,i4,i5,age) = ctmp(i1,i2,i3,i4,i5,idx);			// consumption at that index
					}
				}
			}
		}
	}
}

void CMig6::FindSellCons( int age ){
	int idx;
	TinyVector<int,6> ext;
	ext = s_loc_sell.extent() + 1; // add + 1 here because we have fortran arrays, which are indexed 1,2,...,extent(). So the upper bound of the loop must is extent()+1
	for (int i1=1;i1<ext(0);++i1){		// a
		for (int i2=1;i2<ext(1);++i2){	// y
			for (int i3=1; i3<ext(2); ++i3){	//p
				for (int i4=1; i4<ext(3); ++i4){	//here
					for (int i5=1; i5<ext(4); ++i5){	//there

						idx                            = s_loc_sell(i1,i2,i3,i4,i5,age);	// savings choice at that index
						c_loc_sell(i1,i2,i3,i4,i5,age) = ctmp(i1,i2,i3,i4,i5,idx);			// consumption at that index
					}
				}
			}
		}
	}
}

void CMig6::FindRentCons( int age ){
	int idx;
	TinyVector<int,6> ext;
	ext = s_loc_rent.extent() + 1; // add + 1 here because we have fortran arrays, which are indexed 1,2,...,extent(). So the upper bound of the loop must is extent()+1
	for (int i1=1;i1<ext(0);++i1){		// a
		for (int i2=1;i2<ext(1);++i2){	// y
			for (int i3=1; i3<ext(2); ++i3){	//p
				for (int i4=1; i4<ext(3); ++i4){	//here
					for (int i5=1; i5<ext(4); ++i5){	//there

						idx                            = s_loc_rent(i1,i2,i3,i4,i5,age);	// savings choice at that index
						c_loc_rent(i1,i2,i3,i4,i5,age) = ctmp(i1,i2,i3,i4,i5,idx);			// consumption at that index
					}
				}
			}
		}
	}
}


void CMig6::FindBuyCons( int age ){
	int idx;
	TinyVector<int,6> ext;
	ext = s_loc_buy.extent() + 1; // add + 1 here because we have fortran arrays, which are indexed 1,2,...,extent(). So the upper bound of the loop must is extent()+1
	for (int i1=1;i1<ext(0);++i1){		// a
		for (int i2=1;i2<ext(1);++i2){	// y
			for (int i3=1; i3<ext(2); ++i3){	//p
				for (int i4=1; i4<ext(3); ++i4){	//here
					for (int i5=1; i5<ext(4); ++i5){	//there

						idx                            = s_loc_buy(i1,i2,i3,i4,i5,age);	// savings choice at that index
						c_loc_buy(i1,i2,i3,i4,i5,age) = ctmp(i1,i2,i3,i4,i5,idx);			// consumption at that index
					}
				}
			}
		}
	}
}


void CMig6::ComputePeriod(int age){

	// if final operiod, then preComputed resources are utility
	// unfortunately TinyVector dim_ayp_here_t only available as C++ array, so different indexing for those.
	if (age==dim_ayp_here_t(4)) {
		// EV(a,y,p,here,age)
		EVown( Range::all(),Range::all(),Range::all(),Range::all(),age) = ResStay(Range::all(),Range::all(),Range::all(),Range::all(),1,age,dim_ayp_here_t(0));	//dim_ayp_here_t(0) is index of last element in savings vector.
		EVrent(Range::all(),Range::all(),Range::all(),Range::all(),age) = ResRent(Range::all(),Range::all(),Range::all(),Range::all(),1,age,dim_ayp_here_t(0));

	} else {

		ComputeStay(age);		// get v_stay 
		ComputeSell(age);		// get v_sell 	
		ComputeRent(age);		// get v_rent 
		ComputeBuy(age);		// get v_buy
		ComputeLocationChoice(age);		// 
		ComputeDchoice(age);		// 
		ComputeExpectations(age);	// get EVown and EVrent
	
	}

}


Array<double,4> CMig6::dchoice4d(Array<double,4> one, Array<double,4> two){

	Array<double,4> ret(dim_ayp_here,FortranArray<4>());

	ret = where(one > two, one, two);

	return(ret);
}

Array<int,4> CMig6::dchoiceID4d(Array<double,4> one, Array<double,4> two){

	Array<int,4> ret(dim_ayp_here,FortranArray<4>());

	ret = where(one > two,1,2);
		  
	return(ret);
}

// computes optimal location choice within each subproblem
void CMig6::ComputeLocationChoice( int age ){
	// source format: (a,y,p,here,there,age)
	// target format: (a,y,p,here,age)
	//
	//firstIndex   i1;	// a
	//secondIndex  i2;    // y
	//thirdIndex   i3;	// p
	//fourthIndex  i4;	// here
	fifthIndex   i5;	// there

	// stay
	v_loc_tmp = v_loc_stay(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age);
	v_stay(   Range::all(),Range::all(),Range::all(),Range::all(),age) = max(v_loc_tmp,i5);
	move_stay(Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(v_loc_tmp,i5);

	// sell
	v_loc_tmp = v_loc_sell(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age);
	v_sell(   Range::all(),Range::all(),Range::all(),Range::all(),age) = max(v_loc_tmp,i5);
	move_sell(Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(v_loc_tmp,i5);

	// rent
	v_loc_tmp = v_loc_rent(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age);
	v_rent(   Range::all(),Range::all(),Range::all(),Range::all(),age) = max(v_loc_tmp,i5);
	move_rent(Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(v_loc_tmp,i5);

	// buy
	v_loc_tmp = v_loc_buy(Range::all(),Range::all(),Range::all(),Range::all(),Range::all(),age);
	v_buy(   Range::all(),Range::all(),Range::all(),Range::all(),age) = max(v_loc_tmp,i5);
	move_buy(Range::all(),Range::all(),Range::all(),Range::all(),age) = maxIndex(v_loc_tmp,i5);
}

void CMig6::ComputeDchoice( int age ){

	Vown( Range::all(),Range::all(),Range::all(),Range::all(),age)  = dchoice4d(  v_stay(Range::all(),Range::all(),Range::all(),Range::all(),age), v_sell(Range::all(),Range::all(),Range::all(),Range::all(),age));
	Down( Range::all(),Range::all(),Range::all(),Range::all(),age)  = dchoiceID4d(v_stay(Range::all(),Range::all(),Range::all(),Range::all(),age), v_sell(Range::all(),Range::all(),Range::all(),Range::all(),age));
	Vrent(Range::all(),Range::all(),Range::all(),Range::all(),age) = dchoice4d(   v_rent(Range::all(),Range::all(),Range::all(),Range::all(),age), v_buy( Range::all(),Range::all(),Range::all(),Range::all(),age));
	Drent(Range::all(),Range::all(),Range::all(),Range::all(),age) = dchoiceID4d( v_rent(Range::all(),Range::all(),Range::all(),Range::all(),age), v_buy( Range::all(),Range::all(),Range::all(),Range::all(),age));
}

void CMig6::ComputeExpectations( int age ){

	EVown( Range::all(),Range::all(),Range::all(),Range::all(),age) = integrate(Vown( Range::all(),Range::all(),Range::all(),Range::all(),age));
	EVrent(Range::all(),Range::all(),Range::all(),Range::all(),age) = integrate(Vrent(Range::all(),Range::all(),Range::all(),Range::all(),age));

}

Array<double,4> CMig6::integrate(Array<double,4> tens){
	
	firstIndex   i1;	// a
	secondIndex  i2;    // y
	thirdIndex   i3;	// p
	fourthIndex  i4;	// here
	fifthIndex   i5;	// there
	
	Array<double,4> ret(dim_ayp_here,FortranArray<4>());

	Array<double,5> tmp(dim_ayp_here_y,FortranArray<5>());	// tmp(i1,i2,i3,i4,i5)
	tmp = tens(i1,i2,i3,i4) * G(i5,i2);
	ret = sum( tmp(i1,i5,i3,i4,i2), i5);
		  
	return(ret);

}

   
   
/*// constructor 4: expose the class directly to R*/
//// TODO can you do 
//// int m = dims(dims.length())
//// Array<double,m>
//CMig6::CMig6(Rcpp::IntegerVector dims,
		   //Rcpp::List pars,
		   //Rcpp::List arrays) :

	//// this is syntactic sugar. an initialiser list. 

	//ResStay(FortranArray<5>()),
    //ResSell(FortranArray<5>()),
	//ResRent(FortranArray<5>()),
    //ResBuy( FortranArray<5>()),

    //v_stay(FortranArray<4>()),	
    //v_sell(FortranArray<4>()),  
    //v_rent(FortranArray<4>()),	
    //v_buy( FortranArray<4>()),   
	//c_stay(FortranArray<4>()),	
	//c_sell(FortranArray<4>()),  
	//c_rent(FortranArray<4>()),	
	//c_buy( FortranArray<4>()),   
	//Vown(  FortranArray<4>()),	
	//Vrent( FortranArray<4>()),	
	//EVown( FortranArray<4>()),	
	//EVrent(FortranArray<4>()),	
	//ctmp(  FortranArray<4>()),  	
	//xtmp(  FortranArray<4>()),  	

	//s_stay(FortranArray<4>()),  
	//s_sell(FortranArray<4>()),  
	//s_rent(FortranArray<4>()),  
	//s_buy( FortranArray<4>()),  
	//Down(  FortranArray<4>()),  
	//Drent( FortranArray<4>()),  
	
	//vplustmp(FortranArray<3>()),
	//G(FortranArray<2>())         
    //{						  
		//// get data out of R lists
		//// 
		//Rcpp::NumericVector R_CO = Rcpp::as<Rcpp::NumericVector>(arrays["consO"]);
		//Rcpp::NumericVector R_CR = Rcpp::as<Rcpp::NumericVector>(arrays["consR"]);
		//Rcpp::NumericVector R_CB = Rcpp::as<Rcpp::NumericVector>(arrays["consB"]);
		//Rcpp::NumericVector R_CS = Rcpp::as<Rcpp::NumericVector>(arrays["consS"]);
		//Rcpp::NumericVector R_G  = Rcpp::as<Rcpp::NumericVector>(arrays["G"]);

		//p.beta = Rcpp::as<double>(data["beta"]);
		//p.myNA = Rcpp::as<double>(data["myNA"]);

		//// map to blitz arrays
		//// ===================
		
		//TinyVector<int,5> D_aypta(dims(0),dims(1),dims(2),dims(3),dims(0));
		//TinyVector<int,4> D_aypt(dims(0),dims(1),dims(2),dims(3));
		//TinyVector<int,4> D_aypa(dims(0),dims(1),dims(2),dims(0));
		//TinyVector<int,4> D_aypy(dims(0),dims(1),dims(2),dims(1));
		//TinyVector<int,3> D_ayp(dims(0),dims(1),dims(2));
		//TinyVector<int,2> D_y(dims(1),dims(1));
		//Array<double,2> G(R_G.begin(),shape(d(1),d(1)),neverDeleteData,FortranArray<2>());
		//Array<double,5> stay(R_CO.begin(),D_aypta,neverDeleteData,FortranArray<5>());
		//Array<double,5> rent(R_CR.begin(),D_aypta,neverDeleteData,FortranArray<5>());
		//Array<double,5> buy( R_CB.begin(),D_aypta,neverDeleteData,FortranArray<5>());
		//Array<double,5> sell(R_CS.begin(),D_aypta,neverDeleteData,FortranArray<5>());

		//// reference the data
		//ResStay.reference(data_stay);
		//ResSell.reference(data_sell);
		//ResRent.reference(data_rent);
		//ResBuy.reference(data_buy );
		//G.reference(data_G);
		//v_stay = 1;
		//v_sell = 2;
		//v_rent = 3;
		//v_buy = 4;
/*}*/


//#endif
























