#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <stdio.h>

using namespace std;
using namespace cv;

void detectAndDraw( Mat& img, CascadeClassifier& cascade, 
                    double scale, const String& outPrefix );

String cascadeName = "haarcascade_mcs_mouth.xml";

int main( int argc, const char** argv )
{
    Mat frame, frameCopy, image;
    const String scaleOpt = "--scale=";
    size_t scaleOptLen = scaleOpt.length();
    String inputName;
    String outPrefix;

    CascadeClassifier cascade;
    double scale = 1;

    if (argc < 3) {
      cerr << "Usage: " << argv[0] 
           << " [--scale=<scale>] <in-img> <out-prefix>" << endl;
      return -1;
    }
    for( int i = 1; i < argc-2; i++ ) {
      if( scaleOpt.compare( 0, scaleOptLen, argv[i], scaleOptLen ) == 0 ) {
        if( !sscanf( argv[i] + scaleOpt.length(), "%lf", &scale ) || 
            scale < 1 ) scale = 1;
        cout << "Scale = " << scale << endl;
      } else if( argv[i][0] == '-' ) {
        cerr << "WARNING: Unknown option %s" << argv[i] << endl;
      }
    }
    inputName.assign(argv[argc-2]);
    outPrefix.assign(argv[argc-1]);

    if( !cascade.load( cascadeName ) ) {
      cerr << "ERROR: Could not load classifier cascade: " 
           << cascadeName << endl;
      return -1;
    }

    if( inputName.empty() ) {
      cerr << "ERROR: You must specify an input name." << endl;
      return -1;
    }
    if( outPrefix.empty() ) {
      cerr << "ERROR: You must specify an output prefix." << endl;
      return -1;
    }
    
    image = imread(inputName, CV_LOAD_IMAGE_GRAYSCALE);
    if(image.empty()) {
      cerr << "ERROR: Image could not been opened." << endl;
      return -1;
    }
    detectAndDraw( image, cascade, scale, outPrefix );
    return 0;
}

void detectAndDraw( Mat& img, CascadeClassifier& cascade, 
                    double scale, const String& outPrefix) {
    int i = 0;
    double t = 0;
    vector<Rect> objects;
    Mat smallImg(cvRound(img.rows/scale),
                 cvRound(img.cols/scale), CV_8UC1);
    resize(img, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
    equalizeHist(smallImg, smallImg);

    t = (double)cvGetTickCount();
    cascade.detectMultiScale( smallImg, objects,
        1.1, 2, 0
        //|CV_HAAR_FIND_BIGGEST_OBJECT
        //|CV_HAAR_DO_ROUGH_SEARCH
        |CV_HAAR_SCALE_IMAGE
        ,
        Size(30, 30) );
    t = (double)cvGetTickCount() - t;
    printf( "detection time = %g ms\n", t/((double)cvGetTickFrequency()*1000.) );
    if (objects.size() == 0) {
      cerr << "WARNING: No objects detected!" << endl;
      return;
    }
    for( vector<Rect>::const_iterator r = objects.begin(); 
         r != objects.end(); r++, i++ ) {
      Rect mouth_rect;
      mouth_rect.x = r->x * scale;
      mouth_rect.y = r->y * scale;
      mouth_rect.width = r->width * scale;
      mouth_rect.height = r->height * scale;
      cv::Mat mouth_mat(img, mouth_rect);
      char outname[100]; 
      sprintf(outname, "%s_%03d.png", outPrefix.c_str(), i);
      cout << "Writing image " << outname 
           << " (W="<<mouth_rect.width<<",H="
           <<mouth_rect.height<<")" << endl;
      cv::imwrite(outname, mouth_mat);
    }
}
