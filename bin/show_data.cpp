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
#include <boost/date_time/posix_time/posix_time.hpp>
// #include <boost/date_time/gregorian/gregorian.hpp>


using namespace std;
using namespace pqxx;
using namespace boost::posix_time;
using boost::posix_time::to_iso_extended_string;
using boost::posix_time::from_time_t;

struct Values{
	int channel_index;
	double value;
	unsigned int sample_time;
	unsigned int sample_time_range;

	bool operator<(const Values &two ) const{
		if( sample_time_range != two.sample_time_range )
			return sample_time_range < two.sample_time_range;
		else if( channel_index != two.channel_index )
			return channel_index < two.channel_index;
		return sample_time < two.sample_time;
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

string conv(double val, int precesion){
	stringstream ssin;
	ssin << setprecision(precesion) << val;
	return ssin.str();
}

int main(int argc, char* argv[])
{

	long long int beg = getTime()*1000000.0;

	fstream file;
	file.open("showLog.txt" , ios::out | ios::app | ios::ate);
	
	file << "passed arguments: (" << argc << ")" << endl;
	for( int i=0 ; i<argc ; i++ )
		file << argv[i] << endl;
	file << endl;

	if( argc != 6 ){
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

		int range_selector = atoi(argv[4]);
		int average = atoi(argv[5]);

		vector <Values> all;
		Values value;

		ptime start(boost::gregorian::date(1970,1,1));
		int sz = 0;

		/* List down all the records */
		for (result::const_iterator c = R.begin(); c != R.end(); ++c) {
			sz++;
			value.value = c[0].as<double>();
			value.channel_index = c[1].as<int>();

			string sample_time;
			sample_time = c[2].as<string>();

			ptime t(time_from_string(sample_time));
			time_t dur = (t - start).total_seconds();

			value.sample_time = dur;
			value.sample_time_range = value.sample_time / range_selector;
			
			/* LOG LOG LOG */
			channels[mp[value.channel_index]].value++;

			all.push_back(value);
		}

		file << "size of result: " << sz << endl << endl;
		file << "each channel_index:" << endl;
		for( int i=0 ; i<channels.size() ; i++ )
		  file << "channel_index: " << channels[i].idx << " " << channels[i].value << endl;
		file << endl;

		sort(all.begin() , all.end());

		for( int j=0 ; j<channels.size() ; j++ )
			channels[j].value = 0;

		int last_sample_time;
		if( all.size() )
			last_sample_time = all[0].sample_time_range;

		if( all.size() ){
			string chartData = "[";

			for( int i=0 ; i<all.size() ; ){
				int sample_time_range = all[i].sample_time_range;
				
				for( int j=last_sample_time+1 ; j<sample_time_range ; j++ ){
					chartData += "[new Date(\"" + to_iso_extended_string(from_time_t(j*range_selector)) + "+00:00" + "\"),";
					// cout << j*range_selector;
					for( int k=0 ; k<channels.size() ; k++ ){
						if( k ){
							chartData += "," + conv(channels[k].value , 4);
							// cout << "," << setprecision(5) << channels[k].value;
						}
						else
							chartData += conv(channels[k].value, 4);
							// cout << "#" << setprecision(5) << channels[k].value;
					}
					chartData += "],";
				}

				last_sample_time = sample_time_range;

				while( i<all.size() && all[i].sample_time_range == sample_time_range ){
					int channel_index = all[i].channel_index;
					int cnt = 0;
					double sum = 0;
					double mn = 1000000000;
					double mx = -1000000000;
					while( i<all.size() && all[i].sample_time_range == sample_time_range && all[i].channel_index == channel_index){
						cnt++;
						sum += all[i].value;
						mn = min(mn, all[i].value);
						mx = max(mx, all[i].value);
						i++;
					}
					if( average == 0 )
						channels[mp[channel_index]].value = (double)sum / (double)cnt;
					else if( average == 1 )
						channels[mp[channel_index]].value = all[i-1].value;
					else if( average == 2 )
						channels[mp[channel_index]].value = mx;
					else
						channels[mp[channel_index]].value = mn;
					
					//file << ">> " << channel_index << " " << sample_time_range << " " << channels[mp[channel_index]].value << endl;
				}

				chartData += "[new Date(\"" + to_iso_extended_string(from_time_t(sample_time_range*range_selector)) + "+00:00" + "\"),";
				// cout << j*range_selector;
				for( int k=0 ; k<channels.size() ; k++ ){
					if( k ){
						chartData += "," + conv(channels[k].value , 4);
						// cout << "," << setprecision(5) << channels[k].value;
					}
					else
						chartData += conv(channels[k].value, 4);
						// cout << "#" << setprecision(5) << channels[k].value;
				}
				if( i+1 < all.size()  )
					chartData += "],";
				else
					chartData += "]]";
			}
			printf("%s", chartData.c_str());
		}
		else{
			printf("%s", "[]");
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
