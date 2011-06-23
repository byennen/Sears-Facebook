$(document).ready(function()
{
  $.ajax({
    type: "GET",
    url: "sample_response.xml",
    dataType: "xml",
    success: parseXml
  });
});

function parseXml(xml)
{
  $(xml).find("GiftRegistryItem").each(function()
  {
    $("#output").append('<img src="' + $(this).find("ImageURL").text() + '"/>');
    $("#output").append('<p>' + $(this).find("ItemName").text() + '</p>');
  });
}