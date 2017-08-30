g++ show_data.cpp -I$PWD -L$PWD -lpqxx -lpq -lboost_date_time -o show_data
g++ export_standard.cpp -I$PWD -L$PWD -lpqxx -lpq -lboost_date_time -o export_standard
g++ export_shown_data.cpp -I$PWD -L$PWD -lpqxx -lpq -lboost_date_time -o export_shown_data
g++ usb_parser.cpp -o usb_parser
g++ packet_parser.cpp -o packet_parser


