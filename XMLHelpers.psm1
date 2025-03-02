# Given a [System.Xml.XmlNode] instance, returns the path to it
# inside its document in XPath form.
# Supports element, attribute, and text/CDATA nodes.
# https://stackoverflow.com/questions/24043313/find-xml-nodes-full-xpath
function Get-NodeXPath {
    param (
        [ValidateNotNull()]
        [System.Xml.XmlNode] $node
    )
  
    if ($node -is [System.Xml.XmlDocument]) { return '' } # Root reached
    $isAttrib = $node -is [System.Xml.XmlAttribute]
  
    # IMPORTANT: Use get_*() accessors for all type-native property access,
    #            to prevent name collision with Powershell's adapted-DOM ETS properties.
  
    # Get the node's name.
    $name = if ($isAttrib) {
        '@' + $node.get_Name()
      } elseif ($node -is [System.Xml.XmlText] -or $node -is [System.Xml.XmlCDataSection]) {
        'text()'
      } else { # element
        $node.get_Name()
      }
  
    # Count any preceding siblings with the same name.
    # Note: To avoid having to provide a namespace manager, we do NOT use
    #       an XPath query to get the previous siblings.
    $prevSibsCount = 0; $prevSib = $node.get_PreviousSibling()
    while ($prevSib) {
      if ($prevSib.get_Name() -ceq $name) { ++$prevSibsCount }
      $prevSib = $prevSib.get_PreviousSibling()
    }
  
    # Determine the (1-based) index among like-named siblings, if applicable.
    $ndx = if ($prevSibsCount) { '[{0}]' -f (1 + $prevSibsCount) }
  
    # Determine the owner / parent element.
    $ownerOrParentElem = if ($isAttrib) { $node.get_OwnerElement() } else { $node.get_ParentNode() }
  
    # Recurse upward and concatenate with "/"
    "{0}/{1}" -f (Get-NodeXPath $ownerOrParentElem), ($name + $ndx)
  }

# An empty node
function New-EmptyNode{
  param (
    [String]
    $name
  )
  [xml]"<$name></$name>"
}

# 
function Add-NodeIfNone {
  param (
    [String]
    $xpath,
    [String]
    $name,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $doc
  )
  Select-XML $doc -XPath $xpath
  | Where-Object {$_.Node.ChildNodes.Name -NotContains $name}
  | ForEach-Object {Add-SubNode $_ (New-EmptyNode $name) $doc} 
  | Out-Null
}

# Append a node as subnode to another node in a document
function Add-UniqueSubNodeAt {
  param (
    [String]
    $xpath,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $inserted,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $doc
  )
  $inSerial = $inserted.OuterXML;
  Select-XML $doc -XPath $xpath
  | Where-Object {$_.Node.ChildNodes.OuterXML -NotContains $inSerial}
  | ForEach-Object {Add-SubNode $_ $inserted $doc} | Out-Null
}

# Append a node as subnode to another node in a document
function Add-MultUniqueSubNodeAt {
  param (
    [String]
    $xpath,
    [ValidateNotNull()]
    [System.Xml.XmlDocument[]]
    $inserted,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $doc
  )
  $inserted | ForEach-Object {Add-UniqueSubNodeAt $xpath $_ $doc} | Out-Null
}

# Append a node as subnode to another node in a document
function Add-SubNode {
  param (
    $nodeParent,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $nodeInsert,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $doc
  )
  $imported = $doc.ImportNode($nodeInsert.FirstChild, $true);
  $nodeParent.Node.AppendChild($imported) | Out-Null
  $doc
}

# Append many nodes as subnode to another node in a document
function Add-SubNodes {
  param (
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $nodeParent,
    [ValidateNotNull()]
    [System.Xml.XmlDocument[]]
    $nodeInsert,
    [ValidateNotNull()]
    [System.Xml.XmlDocument]
    $doc
  )
  $nodesInsert | ForEach-Object {
    $imported = $doc.ImportNode($_, $true);
    $nodeParent.Node.AppendChild($imported) | Out-Null
  }
  $doc
}