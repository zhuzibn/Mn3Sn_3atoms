/* Verification-only deterministic transcription of the six-spin model.
 * Compile with -DLEGACY_STAGE to reproduce the archived half-step defect.
 * Usage: diagnostic output.csv seed_deg field_T current_Apm2
 *                   runtime_ns start_ns width_ns dt_fs [initial_6x3.csv]
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef double State[6][3];
static const double alpha = 0.003, gamma0 = 1.760859644e11;
static double dt;
static const double hex = 100.812;
#ifdef LEGACY_STAGE
#define FOURTH_STAGE 0.5
#else
#define FOURTH_STAGE 1.0
#endif
static double axes[3][3], hk, dmi;

static void cross3(const double a[3], const double b[3], double c[3]) {
    c[0]=a[1]*b[2]-a[2]*b[1];
    c[1]=a[2]*b[0]-a[0]*b[2];
    c[2]=a[0]*b[1]-a[1]*b[0];
}

static void fields(const State m, double field, State h) {
    for (int i=0;i<6;i++) {
        int base=i<3?0:3, local=i-base;
        /* Match the ascending-neighbor expression order in field_eta.m. */
        int j=base+(local==0?1:0), k=base+(local==2?1:2);
        double dot=0;
        if (i<3) for(int q=0;q<3;q++) dot+=axes[i][q]*m[i][q];
        for(int q=0;q<3;q++)
            h[i][q]=(i<3?hk*dot*axes[i][q]:0)+(q==1?field:0)
                +(-hex*m[j][q]-hex*m[k][q]);
    }
    h[0][1]+=-dmi*(m[1][2]-m[2][2]);
    h[0][2]+=-dmi*(m[2][1]-m[1][1]);
    h[1][1]+=-dmi*(-m[0][2]+m[2][2]);
    h[1][2]+=-dmi*(m[0][1]-m[2][1]);
    h[2][1]+=-dmi*(-m[1][2]+m[0][2]);
    h[2][2]+=-dmi*(m[1][1]-m[0][1]);
}

static void rhs(const State m, const State h, double b, State out) {
    const double p[3]={1,0,0};
    double scale=gamma0/(1+alpha*alpha);
    for(int i=0;i<6;i++) {
        double mh[3],mmh[3],mp[3],mmp[3];
        cross3(m[i],h[i],mh); cross3(m[i],mh,mmh);
        cross3(m[i],p,mp); cross3(m[i],mp,mmp);
        for(int q=0;q<3;q++) {
            double torque=i<3?b:0;
            out[i][q]=scale*(-mh[q]-alpha*mmh[q]-torque*mmp[q]
                +alpha*torque*mp[q]);
        }
    }
}

static void step(State m, double field, double b) {
    State h,k1,k2,k3,k4,u;
    fields(m,field,h); rhs(m,h,b,k1);
    for(int i=0;i<6;i++) for(int q=0;q<3;q++) u[i][q]=m[i][q]+k1[i][q]*dt/2;
    fields(u,field,h); rhs(u,h,b,k2);
    for(int i=0;i<6;i++) for(int q=0;q<3;q++) u[i][q]=m[i][q]+k2[i][q]*dt/2;
    fields(u,field,h); rhs(u,h,b,k3);
    for(int i=0;i<6;i++) for(int q=0;q<3;q++) u[i][q]=m[i][q]+k3[i][q]*dt*FOURTH_STAGE;
    fields(u,field,h); rhs(u,h,b,k4);
    for(int i=0;i<6;i++) {
        double norm=0;
        for(int q=0;q<3;q++) {
            m[i][q]+=dt/6*(k1[i][q]+2*k2[i][q]+2*k3[i][q]+k4[i][q]);
            norm+=m[i][q]*m[i][q];
        }
        norm=sqrt(norm);
        for(int q=0;q<3;q++) m[i][q]/=norm;
    }
}

static void output(FILE *f, const State m, long completed, long count, double runtime) {
    fprintf(f,"%.17g,%.17g",completed*(runtime/(count-1)),completed*dt);
    for(int q=0;q<3;q++) for(int i=0;i<6;i++) fprintf(f,",%.17g",m[i][q]);
    fputc('\n',f);
}

int main(int argc,char **argv) {
    if(argc!=9 && argc!=10) {fprintf(stderr,"Expected 8 arguments and optional seed CSV\n");return 2;}
    double pi=acos(-1),theta=strtod(argv[2],0)/180*pi;
    double field=strtod(argv[3],0),current=strtod(argv[4],0);
    double runtime=strtod(argv[5],0)*1e-9;
    dt=strtod(argv[8],0)*1e-15;
    if (!(dt>0)) return 2;
    long sample=lround(0.25e-12/dt);
    if(sample<1) return 2;
    long count=lround(runtime/dt),on=lround(strtod(argv[6],0)*1e-9/dt);
    long width=lround(strtod(argv[7],0)*1e-9/dt);
    if(count<2 || on<0 || width<0 || on+width>count) return 2;
    hk=2*(0.196*1e-3*1.602e-19)/(3*9.274e-24);
    dmi=(0.833*1e-3*1.602e-19)/(3*9.274e-24);
    double a[3]={1*pi/6,9*pi/6,5*pi/6};
    for(int i=0;i<3;i++){axes[i][0]=0;axes[i][1]=sin(a[i]);axes[i][2]=cos(a[i]);}
    double theta_b=150.0/180*pi;
    double angles[6]={theta,theta+120.0/180*pi,theta+240.0/180*pi,
        theta_b,theta_b+240.0/180*pi,theta_b+120.0/180*pi};
    State m;
    for(int i=0;i<6;i++) {
        m[i][0]=sin(angles[i])*cos(90.0/180*pi);
        m[i][1]=sin(angles[i])*sin(90.0/180*pi);m[i][2]=cos(angles[i]);
    }
    if(argc==10) {
        FILE *seed=fopen(argv[9],"r"); if(!seed) return 3;
        for(int i=0;i<6;i++) if(fscanf(seed," %lf,%lf,%lf",&m[i][0],&m[i][1],&m[i][2])!=3) return 3;
        fclose(seed);
    }
    double jp=2*30e-9*(441.85*1e3)/6.58211951440e-16;
    double b=0.06*current/jp;
    FILE *out=fopen(argv[1],"w"); if(!out) return 3;
    output(out,m,0,count,runtime);
    for(long ct=1;ct<count;ct++) {
        int driven=ct>on && ct<=on+width;
        step(m,driven?field:0,driven?b:0);
        if(ct%sample==0) output(out,m,ct,count,runtime);
    }
    fclose(out);
    double mo[3]={0,0,0};
    for(int q=0;q<3;q++) for(int i=0;i<3;i++) mo[q]+=m[i][q]/3;
    printf("%s final angle %.10f deg, mean spin [%.10g, %.10g, %.10g]\n",
        argv[1],atan2(mo[1],mo[2])*180/pi,mo[0],mo[1],mo[2]);
    return 0;
}
