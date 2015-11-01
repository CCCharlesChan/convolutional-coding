close all;
clear all;
clc;

dataFile = randi([0, 1], 1024, 1); % 1KB
CRC_poly = [1; 1; 0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1]; % CRC_12: x^12+x^11+x^3+x^2+x+1

PSNR = -10: 1: 40; % dB
% block error ratio
block_err_hard2 = zeros(size(PSNR)); block_err_hard3 = zeros(size(PSNR));
block_err_soft2 = zeros(size(PSNR)); block_err_soft3 = zeros(size(PSNR));
% fail ratio
fail_ratio_hard2 = zeros(size(PSNR)); fail_ratio_hard3 = zeros(size(PSNR));
fail_ratio_soft2 = zeros(size(PSNR)); fail_ratio_soft3 = zeros(size(PSNR));
% bit error ratio
error_ratio_hard2 = zeros(size(PSNR)); error_ratio_hard3 = zeros(size(PSNR));
error_ratio_soft2 = zeros(size(PSNR)); error_ratio_soft3 = zeros(size(PSNR));

for i = 1: length(PSNR)
	for j = 1: 100
		signal_2 = conv_send(dataFile, 1, 2, CRC_poly);
		signal_noCRC_2 = conv_send(dataFile, 1, 2, []);
		signal_3 = conv_send(dataFile, 1, 3, CRC_poly);
		signal_noCRC_3 = conv_send(dataFile, 1, 3, []);
	
		signal_2n = transmit(signal_2, PSNR);
		signal_noCRC_2n = transmit(signal_noCRC_2, PSNR);
		signal_3n = transmit(signal_3, PSNR);
		signal_noCRC_3n = transmit(signal_noCRC_3, PSNR);
		
		[file_dec_hard2, ~] = conv_rec(signal_2n, 1, 2, CRC_poly, 1); 
		difference = xor(file_dec_hard2, dataFile);
		error_ratio_hard2(i) = error_ratio_hard2(i) + sum(difference)/length(dataFile);
		if(sum(difference) ~= 0)
			fail_ratio_hard2(i) = fail_ratio_hard2(i) + 1;
		end

		[file_dec_hard3, ~] = conv_rec(signal_3n, 1, 3, CRC_poly, 1);		
		difference = xor(file_dec_hard3, dataFile);
		error_ratio_hard3(i) = error_ratio_hard3(i) + sum(difference)/length(dataFile);
		if(sum(difference) ~= 0)
			fail_ratio_hard3(i) = fail_ratio_hard3(i) + 1;
		end

		[file_dec_soft2, ~] = conv_rec(signal_2n, 1, 2, CRC_poly, 0);
		difference = xor(file_dec_soft2, dataFile);
		error_ratio_soft2(i) = error_ratio_soft2(i) + sum(difference)/length(dataFile);
		if(sum(difference) ~= 0)
			fail_ratio_soft2(i) = fail_ratio_soft2(i) + 1;
		end

		[file_dec_soft3, ~] = conv_rec(signal_3n, 1, 3, CRC_poly, 0);		
		difference = xor(file_dec_soft3, dataFile);
		error_ratio_soft3(i) = error_ratio_soft3(i) + sum(difference)/length(dataFile);
		if(sum(difference) ~= 0)
			fail_ratio_soft3(i) = fail_ratio_soft3(i) + 1;
		end

		[file_dec_noCRC_hard2, block_err] = conv_rec(signal_noCRC_2n, 1, 2, [], 1);
		block_err_hard2(i) = block_err_hard2(i) + block_err;

		[file_dec_noCRC_hard3, block_err] = conv_rec(signal_noCRC_3n, 1, 3, [], 1);
		block_err_hard3(i) = block_err_hard3(i) + block_err;

		[file_dec_noCRC_soft2, block_err] = conv_rec(signal_noCRC_2n, 1, 2, [], 0);
		block_err_soft2(i) = block_err_soft2(i) + block_err;

		[file_dec_noCRC_soft3, block_err] = conv_rec(signal_noCRC_3n, 1, 3, [], 0);
		block_err_soft3(i) = block_err_soft3(i) + block_err;

	end

	% average of 100 times
	block_err_hard2(i) = block_err_hard2(i)/100; block_err_hard3(i) = block_err_hard3(i)/100;
	block_err_soft2(i) = block_err_soft2(i)/100; block_err_soft3(i) = block_err_soft3(i)/100;
	error_ratio_hard2(i) = error_ratio_hard2(i)/100; error_ratio_hard3(i) = error_ratio_hard3(i)/100;
	error_ratio_soft2(i) = error_ratio_soft2(i)/100; error_ratio_soft3(i) = error_ratio_soft3(i)/100;
	fail_ratio_hard2(i) = fail_ratio_hard2(i)/100; fail_ratio_hard3(i) = fail_ratio_hard3(i)/100;
	fail_ratio_soft2(i) = fail_ratio_soft2(i)/100; fail_ratio_soft3(i) = fail_ratio_soft3(i)/100;

end

c = jet(4);

figure; 
plot(PSNR, block_err_hard2, 'Color', c(1, :)); hold on;
plot(PSNR, block_err_hard3, 'Color', c(2, :)); hold on;
plot(PSNR, block_err_soft2, 'Color', c(3, :)); hold on;
plot(PSNR, block_err_soft3, 'Color', c(4, :)); 
xlabel('PSNR(dB)'); ylabel('block error ratio');
legend('1/2, hard dicision', '1/3, hard dicision', '1/2, soft dicision', '1/3, soft dicision');

figure;
plot(PSNR, error_ratio_hard2, 'Color', c(1, :)); hold on;
plot(PSNR, error_ratio_hard3, 'Color', c(2, :)); hold on;
plot(PSNR, error_ratio_soft2, 'Color', c(3, :)); hold on;
plot(PSNR, error_ratio_soft3, 'Color', c(4, :)); 
xlabel('PSNR(dB)'); ylabel('bit error ratio (without CRC)');
legend('1/2, hard dicision', '1/3, hard dicision', '1/2, soft dicision', '1/3, soft dicision');

figure;
plot(PSNR, fail_ratio_hard2, 'Color', c(1, :)); hold on;
plot(PSNR, fail_ratio_hard3, 'Color', c(1, :)); hold on;
plot(PSNR, fail_ratio_soft2, 'Color', c(1, :)); hold on;
plot(PSNR, fail_ratio_soft3, 'Color', c(1, :)); 
xlabel('PSNR(dB)'); ylabel('fail\_to\_send\_file ratio');
legend('1/2, hard dicision', '1/3, hard dicision', '1/2, soft dicision', '1/3, soft dicision');