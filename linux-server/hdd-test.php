<?php

// TODO: This is a very old script, it needs re-writing from scratch

$smartctl   = 'smartctl -a ';
$hdd_device = '/dev/sda';
$supervisor_1 = 'supervisor1@gmail.com';
$supervisor_2 = 'supervisor2@gmail.com';
$server       = 'website.com';
$sendmail   = '/usr/sbin/exim ';
$current_ip = '1.2.3.4';

exec($smartctl.$hdd_device, $output);

foreach ($output as $line) {
	// Looking for the reallocated sectors amount
	if (strpos($line, 'Reallocated_Sector')) {
		$reallocated = (int)substr($line, -5, 5);

		// Sending e-mail if the hard-drive begins to fail
		if ($reallocated) {
			// Date example: Mon, 4 Dec 2006 15:51:37 +0100
			$message = 'date: '.date("D, d M Y H:i:s O", time()).PHP_EOL.
					   'to: '.$supervisor_1.PHP_EOL.
					   'cc: '.$supervisor_2.PHP_EOL.
					   'subject: HDD on '.$current_ip.' is going to crash!'.PHP_EOL.
					   'from: '.$server.PHP_EOL.

					   'HDD is going to crash on the server '.$current_ip.PHP_EOL.
					   'Total reallocated sectors on '.$hdd_device.': '.$reallocated.PHP_EOL.PHP_EOL.
					   'Please take a look ASAP'.PHP_EOL.
					   '______________________________'.PHP_EOL.
					   'hdd-test script (from cron)';

			$mail_path = '/store/www/message.mail';
			$mail_handle = fopen($mail_path, 'c');
			fwrite($mail_handle, $message);
			fclose($mail_handle);

			exec($sendmail.' -i "'.$supervisor_1.', '.$supervisor_2.'" < '.$mail_path);
			// when using /usr/sbin/exim, do this instead of the line above:
			// exec($sendmail.' -i -t '.$supervisor_1.' < '.$mail_path);      -t means sending to both recipients
			unlink($mail_path);
		}
	}
}
