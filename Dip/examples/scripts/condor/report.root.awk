#parser for decomp output
REPORT=$1
NAME=$2
TIME=$3

#break up name of file to give instance name in first column
awk -F'.' '{print $1 " ->" $0'} $1 > tmp.root

#change INF to 999999
sed 's/INF/999999/' tmp.root > tmp2.root

# $1     , $22, $13, $16,    
#instance, time, LB,  UB, gap

awk -v time="$TIME" '
{
   timeLim = time-(time/20);
   if($7 == 999999){ #no ub
      if($22 >= timeLim){ #exceed time
         printf "%15s & T        & %10.2f & $\\infty$ & $\\infty$\n", 
            $1,$5;
      }
      else{
         #no ub, did not exceed time limit <-- error?
         printf "%15s & %8.2f & & %10.2f & $\\infty$ & $\\infty$\n",   
            $1,$22,$5;
      }
   }
   else{
      #if ub is negative, will need to flip in gap calc for absolute value
      if($7 >= 0){ mult=1 } else {mult=-1};
      gap = 100*($7-$5)/(mult*$7);
      if($22 >= timeLim){ #exceed time
         printf "%15s & T        & %10.2f & %10.2f & %8.2f\\%\n", 
            $1,$5,$7,gap; 
      }  
      else{
         if(gap <= 0.0000001){
            printf "%15s & %8.2f & %10.2f & %10.2f & OPT\n", 
               $1,$22,$5,$7;
         }
         else{
            printf "%15s & %8.2f & %10.2f & %10.2f & %8.2f\\%\n", 
               $1,$13,$5,$7,gap;
         }
      }
   }
}' tmp2.root > tmp3.root
sort tmp3 > ${NAME}.${TIME}.root


