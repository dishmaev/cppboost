/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * File:   main.cpp
 * Author: dmitry
 *
 * Created on November 8, 2017, 8:04 AM
 */

#include <boost/regex.hpp>
#include <iostream>
#include <string>

int main()
{
    using namespace std;

//    string line;
    boost::regex pat( "^Subject: (Re: |Aw: )*(.*)" );

    cout<<"Hello world with first feature!"<<endl;

//    while (std::cin)
//    {
//        getline(std::cin, line);
//        boost::smatch matches;
//        if (boost::regex_match(line, matches, pat))
//            cout << matches[2] << endl;
//    }
}
