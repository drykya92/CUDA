#include <stdio.h>
#include <math.h>
#include <conio.h>
#include <stdlib.h>
#include "cuda.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
# include "device_functions.h" 
# include "time.h"
 
#define indis(a,b,c) ( a* b + c) 
#define siraBul(a,b,c,d) ( a + b * c * d)
 
 
 
__global__ void obebi(int buyuk, int kucuk, int *sonuc)
{
	unsigned int i = indis(blockIdx.x,blockDim.x , threadIdx.x); 
    unsigned int j = indis(blockIdx.y,blockDim.y , threadIdx.y);  
	int sira = siraBul(i , j, blockDim.x , gridDim.x);  
	
     __syncthreads();  
	if(sira >kucuk)
		return; 
	// sira > kucuk sayı olunca  dönüyor çünkü  küçük sayı kadar thread var 
 
	if(buyuk % sira == 0 && kucuk % sira == 0) 
	   atomicMax(sonuc,sira);	
	// büyük sayiyla küçük sayinin ortak bölenlerini sırasıyla bulunup yazılıyor
	// bir ortak bölen bulunduğunda  yazılıyor arama devam ettiği sürece tekrar 
	// bir ortak bölen bulunca karşılaştırıp büyük olanı yazdırıyor böylece sonuca ulaşıyoruz
} 
int main()
{   
	int bir, iki;
	printf("1. sayiyi giriniz:" );
	scanf("%d", &bir);
	printf("2. sayiyi giriniz:" );
	scanf("%d", &iki);
 
	int buyuk = 0;
	int kucuk = 0;
 
	if(bir > iki)
	{
		buyuk = bir;
		kucuk = iki;
	}
	else 
	{
		buyuk = iki;
		kucuk = bir;
	}
	 //küçük sayıyı bulmak için kontrol blokları
	int *ay_resim ;	     
 
	int *sonuc = (int*)malloc( sizeof(int));   
 
		int M = 256;
		int N = 256;
 
		if(kucuk <512)
			N = 1 ;
		else 
			N = (int)(kucuk / 512) + 1;  
  
		
		int *ay_sonuc; 
		cudaMalloc((void**)&ay_sonuc, sizeof(int));  
		obebi<<<M,N>>>(buyuk, kucuk, ay_sonuc);	 
		cudaMemcpy( sonuc, ay_sonuc, sizeof(int), cudaMemcpyDeviceToHost);		  
		cudaFree(ay_sonuc);
		 //cudaMalloc() ile GİB belleği üzerinde yer ayrılmalır.
		//en son olarak ta cudaFree() ilebu bellek alanları boşaltılır.
		// <<<m,n>>>ifadesi içerisinde kodun kaç öbek ve kaç iş parçacığı içerisinde icra edileceği görülmektedir. 
		//İş parçacıklarının öbekler içerisinde  bulunduğuna daha önce değinilmişti. 
		//Dolayısıyla toplamda öbek sayısı x iş parçacığı sayısıkadar iş parçacığı üzerinde kod icra edilmiş olmaktadır. 
		//Mesela  <<<10,20>>> ifadesiiçin 10 x 20 = 200 tane iş parçacığı çalışmış olur.
		
		printf("islem sonucu : %d", sonuc[0]); 
		free(sonuc); 
		// sonuc için açılan yer boşaltılıyor
		getch();
 
 
    return 0;
} 
