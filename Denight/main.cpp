//////////////////////////////////////////////////////////////////////////
//  Image denight
//	'A multiscale retinex for bridging the gap between color images and human observation of scenes'
//	fengjie@pku.cis
//	2009-11-3
//////////////////////////////////////////////////////////////////////////

#include <opencv2\opencv.hpp>
#include <cmath>
#include <iostream>
#include <fstream>
using namespace std;
using namespace cv;


//////////////////////////////////////////////////////////////////////////
//	shift
//////////////////////////////////////////////////////////////////////////
bool ShiftDFT(Mat& src_arr, Mat& dst_arr )
{
	Mat tmp;
	Mat q1stub, q2stub;
	Mat q3stub, q4stub;
	Mat d1stub, d2stub;
	Mat d3stub, d4stub;
	Mat q1, q2, q3, q4;
	Mat d1, d2, d3, d4;

	Size size(src_arr.cols, src_arr.rows);
	Size dst_size(dst_arr.cols, dst_arr.rows);
	int cx, cy;

	if(dst_size.width != size.width || 
		dst_size.height != size.height){
			//cvError( CV_StsUnmatchedSizes, "cvShiftDFT", "Source and Destination arrays must have equal sizes", __FILE__, __LINE__ ); 
		return false;
	}

	if(src_arr.data == dst_arr.data){
		tmp.create(size.height/2, size.width/2, src_arr.depth());
	}

	cx = ((double)size.width/2);
	cy = cvFloor((double)size.height/2); // image center

	// reference
	q1 = src_arr(Rect(0, 0, cx, cy));
	q2 = src_arr(Rect(cx, 0, cx, cy));
	q3 = src_arr(Rect(cx, cy, cx, cy));
	q4 = src_arr(Rect(0, cy, cx, cy));
	d1 = dst_arr(Rect(0, 0, cx, cy));
	d2 = dst_arr(Rect(cx, 0, cx, cy));
	d3 = dst_arr(Rect(cx, cy, cx, cy));
	d4 = dst_arr(Rect(0, cy, cx, cy));

	if(src_arr.data != dst_arr.data){
		if( q1.depth() != d1.depth()){
			//cvError( CV_StsUnmatchedFormats, "cvShiftDFT", "Source and Destination arrays must have the same format", __FILE__, __LINE__ ); 
			return false;
		}

		q3.copyTo(d1);
		q4.copyTo(d2);
		q1.copyTo(d3);
		q2.copyTo(d4);
	}
	else{
		q3.copyTo(tmp);
		q1.copyTo(q3);
		tmp.copyTo(q1);
		q4.copyTo(tmp);
		q2.copyTo(q4);
		tmp.copyTo(q2);
	}

	return true;
}


//////////////////////////////////////////////////////////////////////////
//	do convolution in Frequency domain
//	@return		final image after convolution
//////////////////////////////////////////////////////////////////////////
Mat cvFFTConvolution(const Mat& channel, const Mat& kernel)
{
	//create complex image and kernel
	//////////////////////////////////////////////////////////////////////////
	Mat realImg = channel.clone();
	Mat imaginaryImg = channel.clone();
	imaginaryImg.setTo(0);
	Mat complexImg(channel.rows, channel.cols, CV_32FC2);
	vector<Mat> vec_mat;
	vec_mat.push_back( realImg );
	vec_mat.push_back( imaginaryImg );
	merge(vec_mat, complexImg);
	//////////////////////////////////////////////////////////////////////////
	Mat realKernel = kernel.clone();
	Mat imaginaryKernel = kernel.clone();
	imaginaryKernel.setTo(0);
	Mat complexKernel(realKernel.rows, realKernel.cols, CV_32FC2);
	vec_mat[0] = realKernel;
	vec_mat[1] = imaginaryKernel;
	merge(vec_mat, complexKernel);

	//////////////////////////////////////////////////////////////////////////
	int dft_M = getOptimalDFTSize(channel.rows*2-1);
	int dft_N = getOptimalDFTSize(channel.cols*2-1);

	Mat dft_A(channel.rows, channel.cols, CV_32FC2);
	dft_A.setTo(0);
	Mat dft_B(kernel.rows, kernel.cols, CV_32FC2);
	dft_B.setTo(0);
	Mat conv = channel.clone();

	//////////////////////////////////////////////////////////////////////////
	// do dft for image
	//////////////////////////////////////////////////////////////////////////
	Mat tmp = dft_A(Rect(0, 0, channel.cols, channel.rows));
	complexImg.copyTo(tmp);

	dft(dft_A, dft_A, CV_DXT_FORWARD);


	//////////////////////////////////////////////////////////////////////////
	// do dft for kernel
	//////////////////////////////////////////////////////////////////////////
	tmp = dft_B(Rect(0, 0, kernel.cols, kernel.rows));
	complexKernel.copyTo(tmp);

	//do dft
	dft(dft_B, dft_B, CV_DXT_FORWARD);

	//shift kernel to center
	Mat dft_BB = dft_B.clone();
	ShiftDFT(dft_B, dft_BB);
	dft_BB.copyTo(dft_B);

	//////////////////////////////////////////////////////////////////////////
	//	do convolution
	//////////////////////////////////////////////////////////////////////////
	mulSpectrums(dft_A, dft_B, dft_A, CV_DXT_MUL_CONJ);

	//do inverse dft
	dft(dft_A, dft_A, CV_DXT_INV_SCALE, channel.rows);
	Mat realRes(dft_A.rows, dft_A.cols, CV_32F);
	Mat imageRes = realRes.clone();
	vec_mat.clear();
	split(dft_A, vec_mat);
	vec_mat[0].copyTo(realRes);
	vec_mat[1].copyTo(imageRes);
	pow(realRes, 2, realRes);
	pow(imageRes, 2, imageRes);
	realRes += imageRes;
	pow(realRes, 0.5, realRes);

	//copy back
	realRes.copyTo(conv);

	return conv;
}




int main()
{
	//parameters
	int c[3] = {80, 120, 250};	//scale parameters
	float alpha = 125, beta = 46;
	float G = 192, b = -30;

	namedWindow("win",1);
	namedWindow("res",1);

	//obtain image
	Mat img = imread("ada1.jpg");
	Mat dimg(img.rows, img.cols, CV_32FC3);
	img.convertTo(dimg, dimg.depth());
	//split to 3 channels
	vector<Mat> channels(3);
	for(int i=0; i<3; i++)
		channels[i].create(img.rows, img.cols, CV_32F);
	split(dimg, channels);	// bgr

	//////////////////////////////////////////////////////////////////////////
	// generate surround function for 3 scales corresponds different 
	// smooth kernel: std = sqrt(2)/2*c (OK)
	//////////////////////////////////////////////////////////////////////////
	vector<Mat> gaussKernels(3);
	for(int i=0; i<3; i++)
	{
		gaussKernels[i].create(dimg.rows, dimg.cols, CV_32F);
		Point3d center((double)dimg.cols/2, (double)dimg.rows/2, 0.0f);
		double sum = 0;
		for(int j=0; j<gaussKernels[i].rows; j++)
		{
			double y = j-center.y;
			for(int k=0; k<gaussKernels[i].cols; k++)
			{
				double x = k-center.x;
				double val = exp(-(x*x+y*y)/(2*c[i]*c[i]));
				gaussKernels[i].at<float>(j, k) = val;
				sum += val;
			}
		}
		sum = 1.0f/sum;
		//normalize
		gaussKernels[i].convertTo(gaussKernels[i], gaussKernels[i].depth(), sum);
	}

	//////////////////////////////////////////////////////////////////////////
	// MSRCR
	//////////////////////////////////////////////////////////////////////////
	vector<Mat> scales(3);
	for(int i=0; i<3; i++)
		scales[i].create(img.rows, img.cols, CV_32F);
	Mat logimg1(img.rows, img.cols, CV_32F);
	Mat logimg2 = logimg1.clone();
	
	Mat channelSum = logimg1.clone();
	channelSum.setTo(0);
	channelSum += channels[0];
	channelSum += channels[1];
	channelSum += channels[2];

	Mat logtemp = logimg1.clone();

	//process each channel
	for(int i=0; i<3; i++)
	{
		//compute C(i,j)
		Mat colorrestore = channels[i] * alpha;
		colorrestore += 1.0;
		log(colorrestore, logimg1);
		channelSum += 1.0;
		log(channelSum, logimg2);
		colorrestore = logimg1 - logimg2;
		colorrestore *= beta;

		//convert to log
		//avoid being divided by 0
		logtemp = channels[i] += 1.0;
		//compute R(i,j)
		log(logtemp, logimg1);

		//process each scale
		for(int j=0; j<3; j++)
		{
			scales[j] = cvFFTConvolution(channels[i], gaussKernels[j]);
			/*double minv = 0;
			cvMinMaxLoc(res, &minv, 0, 0, 0, 0);
			cvSubS(res, cvRealScalar(minv), scales[j]);*/
			logtemp = scales[j] += 1.0;
			log(logtemp, logimg2);
			scales[j] = logimg1 - logimg2;
		}

		//combine multiscale
		//channels[i].setTo(0);
		channels[i] = scales[0] + scales[1] + scales[2];
		channels[i] *= 1.0/3;
		
		//multiply CRC
		channels[i] = colorrestore.mul(channels[i]);
		channels[i] += b;
		channels[i] *= G;

		
		// linear stretching
		double minval = 0;
		double maxval = 0;
		minMaxLoc(channels[i], &minval, &maxval);
		for(int k=0; k<channels[i].rows; k++)
		{
			for(int kk=0; kk<channels[i].cols; kk++)
			{
				float val = channels[i].at<float>(k, kk);
				if(val < minval)
					channels[i].at<float>(k, kk) = 0;
				else if(val <= maxval)
					channels[i].at<float>(k, kk) = (val-minval)*255/(maxval-minval);
				else
					channels[i].at<float>(k, kk) = 255;
			}
		}
		
	}

	//merge into single image
	merge(channels, dimg);
	//cvConvertScale(dimg, dimg, 255.0f);
	Mat result = img.clone();
	dimg.convertTo(result, result.depth());

	
	imshow("win", img);
	imshow("res", result);
	cvWaitKey(0);

	cvDestroyAllWindows();

	return 0;
}