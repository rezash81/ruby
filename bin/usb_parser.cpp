#include <iostream>
#include <fstream>
#include <sys/time.h>

using namespace std;
ifstream file;

void inp( int &val , int size ){
	unsigned char pp[10];
	file.read((char *)pp , size);
	val = 0;
	for( int i=size-1 ; i>=0 ; i-- ){
		val = (val << 8) | pp[i];
	}
}

double getTime()
{
    timeval tim;
    gettimeofday(&tim, NULL);
    return tim.tv_sec+(tim.tv_usec/1000000.0);
}

int main(int argc, char *argv[]){
	
	long long int beg = getTime()*1000000.0;
	
	if( argc < 2 ){
		return 0;
	}
	
	file.open(argv[1] , fstream::binary | fstream::in | fstream::ate );
	
	if( file.is_open() ){
		int size = file.tellg();
		if( size % 348 == 0 ){
			file.seekg(0 , ios::beg);
			while( file.tellg() < size ){
				int ord , year , month , day , dayW , hour , min , sec , idx , vali , valf;
				inp(ord , 4);
				inp(year , 2);
				inp(month , 1);
				inp(day , 1);
				inp(dayW , 1);
				inp(hour , 1);
				inp(min , 1);
				inp(sec , 1);
				cout << ord << "," << year << "," << month << "," << day << "," << dayW << "," << hour << "," << min << "," << sec;
				for( int i=0 ; i<28 ; i++ ){
					inp(idx , 4);
					inp(vali , 4);
					inp(valf , 4);
					
					//For taking even less storage!
					if( valf == 0 )
						cout << "," << idx << "," << vali;
					else
						cout << "," << idx << "," << vali << "." << valf;
				}
				cout << endl;
			}
		}
	}
	
	//long long int end = getTime()*1000000.0;
	//cout <<  end - beg << endl;
	return 0;
}
