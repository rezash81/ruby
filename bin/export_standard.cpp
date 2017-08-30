#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <sys/time.h>
#include <unistd.h>
#include "pqxx/pqxx"

using namespace std;
using namespace pqxx;

struct Values{
	int sample_ordinal_num, channel_index;
	double value;
	string sample_time;

	bool operator<(const Values &two ) const{
		return sample_ordinal_num < two.sample_ordinal_num;
	}
};

struct ChannelValue{
	int idx;
	double value;
};

double getTime()
{
    timeval tim;
    gettimeofday(&tim, NULL);
    return tim.tv_sec+(tim.tv_usec/1000000.0);
}

int main(int argc, char* argv[])
{

	long long int beg = getTime()*1000000.0;

	fstream file;
	file.open("exportlog.txt" , ios::out | ios::app | ios::ate);
	
	file << "passed arguments: (" << argc << ")" << endl;
	for( int i=0 ; i<argc ; i++ )
		file << argv[i] << endl;
	file << endl;

	if( argc != 4 ){
		file << "Wrong arguments!" << endl;
		file << endl;
		return 1;
	}


	try{
		// dbname=testdb user=postgres password=cohondob
		connection C(argv[1]);
		if(C.is_open() == false) {
			file << "Can't open database" << endl << endl;
			return 1;
		}
		/* Create a non-transactional object. */
		nontransaction N(C);

		/* Execute SQL query */
		result R( N.exec(argv[2]));

		vector <ChannelValue> channels;
		ChannelValue temp;
		string ch(argv[3]);
		stringstream ssin(ch);
		while( ssin >> temp.idx ){
			temp.value = 0;
			channels.push_back(temp);
		}

		map<int , int> mp;
		for( int i=0 ; i<channels.size() ; i++ ){
			mp[channels[i].idx] = i;
		}

		vector <Values> all;
		Values value;

		int sz = 0;

		/* List down all the records */
		for (result::const_iterator c = R.begin(); c != R.end(); ++c) {
			sz++;
			value.value = c[0].as<double>();
			value.sample_time = c[1].as<string>();
			value.sample_ordinal_num = c[2].as<int>();
			value.channel_index = c[3].as<int>();

			all.push_back(value);
		}

		file << "size of result: " << sz << endl << endl;

		sort(all.begin() , all.end());

		for( int i=0 ; i<all.size() ; i++ ){
			int sample_ordinal_num = all[i].sample_ordinal_num;
			string sample_time = all[i].sample_time;
			for( int j=0 ; j<channels.size() ; j++ )
				channels[j].value = 0;
			while( i<all.size() && all[i].sample_ordinal_num == sample_ordinal_num ){
				channels[mp[all[i].channel_index]].value = all[i].value;
				i++;
			}
			i--;

			cout << sample_time << "#" << sample_ordinal_num;
			for( int j=0 ; j<channels.size() ; j++ ){
				if( j )
					cout << "," << setprecision(4) << channels[j].value;
				else
					cout << "#" << setprecision(4) << channels[j].value;
			}
			cout << endl;
		}

		C.disconnect ();
	}catch (const std::exception &e){
		file << "Exception occured! => " << e.what() << endl << endl;
		return 1;
	}

	long long int end = getTime()*1000000.0;
	file <<  (end - beg)/1000.0 << endl << endl;
   return 0;
}
