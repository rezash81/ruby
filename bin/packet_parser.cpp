#include <iostream>
#include <fstream>
#include <sys/time.h>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>
#include <vector>

using namespace std;
ifstream file;
char *cont;
string content;

void inp( string in, int &val){
	val = 0;
	int sz = in.size();
	for( int i=sz-1 ; i>=0 ; i-- ){
		unsigned char cc = (unsigned char) in[i];
		val = (val << 8) | cc;
	}
}

void inp( string in, unsigned int &val){
	val = 0;
	int sz = in.size();
	for( int i=sz-1 ; i>=0 ; i-- ){
		unsigned char cc = (unsigned char) in[i];
		val = (val << 8) | cc;
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
	
	file.open(argv[1], fstream::binary | fstream::in | fstream::ate );

	if( file.is_open() ){
		int sizeInBytes = file.tellg();
		cont = new char[sizeInBytes+10];
		file.seekg(0, ios::beg);
		file.read(cont , sizeInBytes);
		content.assign(cont , sizeInBytes);
		
		vector<string> all;
		string delimiter = "#next_sample#";
		size_t pos = 0;
		string token;
		content += delimiter;

		while((pos = content.find(delimiter)) != std::string::npos ) {
		    token = content.substr(0, pos);
		    if( token.size() >= 16 ){
					all.push_back(token);
		    }
		    content.erase(0, pos + delimiter.length());
		}

		for( int i=0 ; i<all.size() ; i++ ){
			string packet = all[i];
			
			if( packet.size() < 16 )
				continue;
			
			unsigned int ord, sampleOrd, year, month, day, dayW, hour, min, sec, idx, valf;
			int vali;

			inp(packet.substr(0, 4), ord);
			inp(packet.substr(4, 4), sampleOrd);
			inp(packet.substr(8, 2), year);
			inp(packet.substr(10, 1), month);
			inp(packet.substr(11, 1), day);
			inp(packet.substr(13, 1), hour);
			inp(packet.substr(14, 1), min);
			inp(packet.substr(15, 1), sec);

			packet.erase(0 , 16);
			
			if( packet.size() % 12 )
				continue;
			int channel_count = packet.size() / 12;

			cout << ord << "," << sampleOrd << "," << year << "," << month << "," << day << "," << hour << "," << min << "," << sec << "," << channel_count;
			
			for( int j=0 ; j<channel_count ; j++ ){
				inp(packet.substr(0, 4), idx);
				inp(packet.substr(4, 4), vali);
				inp(packet.substr(8, 4), valf);

				packet.erase(0, 12);
				
				//taking even less storage!
				if( valf == 0 )
					cout << "," << idx << "," << vali;
				else
					cout << "," << idx << "," << vali << "." << valf;
			}

			cout << endl;
		}
	}

	//long long int end = getTime()*1000000.0;
	//cout <<  end - beg << endl;
	return 0;
}
