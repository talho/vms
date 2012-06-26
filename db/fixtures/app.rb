
vms = App.find_or_create_by_name('vms')

vms.help_email = 'admins@talho.org' if vms.help_email.blank?
vms.root_jurisdiction = Jurisdiction.find_by_name("Texas") if vms.root_jurisdiction.blank? #if this isn't defined, no worries
vms.login_text = %Q{<p>The TALHO Public Health Information Network (TALHO Phin) is an online portal containing a collection of applications which provide users with a range of functions to carry out public health preparedness goals and duties. <a href="/tutorials/Registering_and_Navigating_The_PHIN_-_Manual.pdf">Click here</a> for a tutorial on registering and navigating the PHIN, and <a href="/tutorials/Health_Alert_Network_Training_-_Manual.pdf">here</a> for Health Alert Network (HAN) training.</p>
<p>To learn more about TALHO Phin, please visit <a href="/about">About OpenPHIN</a></p>} if vms.login_text.blank?
vms.logo = File.open(Rails.root.join('app','assets','images','talho_phin','talho_phin_title.jpg')) if vms.logo_file_name.blank?
vms.tiny_logo = File.open(Rails.root.join('app','assets','images','images','talho_header_logo.png')) if vms.tiny_logo_file_name.blank?
vms.about_label = 'About OpenPHIN' if vms.about_label.blank?
vms.about_text = %Q{<h1>About OpenPHIN</h1>
<p>The TALHO Dashboard is an online site providing numerous public health services, such as disaster volunteer management (VMS), school illness and attendance tracking (Rollcall), and the dissemination of Health Alerts (HAN).  This site is owned and managed by the Texas Association of Local Health Officials.</p>
<p>You can set up contact devices to receive Phin Alerts.  Your account email is your first contact device, and you can add more addresses if you like.  TALHO recommends adding a phone device, and there are also choices for Blackberry PIN messaging and regular text messaging.  Thanks for your participation with TALHO PHIN.</p>
<p>If you encounter any problems in completing these tasks, email support at <a href="mailto:admins@talho.org">admins@talho.org</a></p>
<p>Copyright &cp; 2009 - 2011 Texas Association of Local Health Officials - All Rights Reserved</p>} if vms.about_text.blank?
  
vms.save!

