#include <iostream>
#include <fstream>
#include <iomanip>
#include <cmath>
#include <climits>
using namespace std;

struct ca{
	bool valid;
	int time;
	unsigned int tag;
};
int main(int argc, char *argv[])
{
	int cacheSize, blockSize, associative, rule;
	ifstream inFile(argv[1], ios::in);
	ofstream outFile(argv[2], ios::out);
	inFile >> cacheSize >> blockSize >> associative >> rule;
	int blocksN = cacheSize/blockSize;
	int offsetLen = log(blockSize*4)/log(2);
	unsigned int address;
	int tag, tagLen;
	int indexLen = log(blocksN)/log(2);
	tagLen = 32-indexLen-offsetLen;
	struct ca *cache = new struct ca[blocksN];
	int index;
	int n = 0;
	int times = 0;
	for(int i = 0; i < blocksN; i++){//reset
		cache[i].valid = false;
	} 
	if(associative == 0) {//directed mapped
		int temp = 1;
		for(int i = 0; i < indexLen; i++){
			temp*=2;
		}
		while(inFile>>address){
			n++;
			address*=4;
			index = (address>>offsetLen)%temp;
			if(!cache[index].valid){//miss
				cache[index].valid = true;
				cache[index].tag = address>>(indexLen+offsetLen);
				outFile<<-1<<endl;
				times++;
			}
			else{
				if((address>>(indexLen+offsetLen)) != cache[index].tag){//miss
					outFile<<cache[index].tag<<endl;
					cache[index].tag = (address>>(indexLen+offsetLen));
					times++;
				}
				else{//hit
					outFile <<-1<< endl;
				}
			}
		}
	}
	else if(associative == 1) {//four-way set associative Miss rate = 0.216545
		indexLen = log(blocksN/4)/log(2);
		int temp = 1;
		for(int i = 0; i < indexLen; i++){
			temp*=2;
		}
		while(inFile>>address){
			address*=4;
			bool hit = false;
			index = (address>>offsetLen)%temp;
			for(int i = 4*index; i < 4*index+4; i++){
				if(!cache[i].valid){//miss
					cache[i].tag = address>>(indexLen+offsetLen);
					cache[i].valid = true;
					cache[i].time = n;
					times++;
					hit = true;
					outFile<<-1<<endl;
					break;
				}
				if(cache[i].tag == address>>(indexLen+offsetLen)){//hit
					hit = true;
					cache[i].time = n;
					outFile<<-1<<endl;
					break;
				}				
			}
			//miss
			if(!hit){
				times++;
				if(rule==0){//FIFO
					outFile<<cache[4*index].tag<<endl;
					for(int j = 4*index; j < 4*index+3; j++){
						cache[j] = cache[j+1];
					}
					cache[4*index+3].tag = address>>(indexLen+offsetLen);
					cache[4*index+3].time = n;
				}
				else{//LRU
					long long int least = 4*index;
					for(int j = 4*index+1; j < 4*index+4; j++){
						if(cache[j].time<cache[least].time){
							least = j;
						}
					}
					outFile<<cache[least].tag<<endl;
					cache[least].tag = address>>(indexLen+offsetLen);
					cache[least].time = n;
				}
			}
			n++;
		}
	}
	else if(associative == 2) {//fully associative Miss rate = 0.000597
		while(inFile>>address){
			address*=4;
			bool hit = false;
			for(int i = 0; i < blocksN; i++){
				if(!cache[i].valid){//miss
					cache[i].tag = address>>offsetLen;
					cache[i].valid = true;
					cache[i].time = n;
					times++;
					hit = true;
					outFile<<-1<<endl;
					break;
				}
				if(cache[i].tag == address>>offsetLen){//hit
					hit = true;
					cache[i].time = n;
					outFile<<-1<<endl;
					break;
				}				
			}
			//miss
			if(!hit){
				times++;
				if(rule==0){//FIFO
					outFile<<cache[0].tag<<endl;
					for(int j = 0; j < blocksN-1; j++){
						cache[j] = cache[j+1];
					}
					cache[blocksN-1].tag = address>>offsetLen;
					cache[blocksN-1].time = n;
				}
				else{//LRU
					long long int least = 0;
					for(int j = 1; j < blocksN; j++){
						if(cache[j].time<cache[least].time){
							least = j;
						}
					}
					outFile<<cache[least].tag<<endl;
					cache[least].tag = address>>offsetLen;
					cache[least].time = n;
				}
			}
			n++;
		}
	}
	outFile<<"Miss rate = "<<setprecision(6)<<fixed<<double(times)/double(n)<<endl;
	delete [] cache;
	return 0;
}

