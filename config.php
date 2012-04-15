<?
assert(! $_REQUEST["relative_path"]);

define("SITE_URL", "knowledge-networks.co.nz");

define("DV_RELATIVE_PATH", $relative_path."../dv_manager/");

require(DV_RELATIVE_PATH."configuration.php");
?>
