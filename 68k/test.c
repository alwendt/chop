
main()
{
register double a,b,c,d,e,f,g,h,i,j;

foo(a,b,c,d,e,f,g,h,i,j);
}


foo(){
}

fee() {
    extern double a(),b(),c(),d(),e(),f(),g(),h(),i(),j();
    extern double a1(),b1(),c1(),d1(),e1(),f1(),g1(),h1(),i1(),j1();
    print(
    ((a()+b())*(c()+d())-(e()+f())*(g()+h()))/((a1()+b1())*(c1()+d1())-(e1()+f1())*(g1()+h1()))
    );
    }
