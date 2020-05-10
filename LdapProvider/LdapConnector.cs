using System;
using System.Collections.Generic;
using System.DirectoryServices.ActiveDirectory;
using System.DirectoryServices.Protocols;
using System.Net;

namespace LdapProvider
{
    public class LdapConnector
    {
        private byte[] _cookie = new byte[262144]; // Init to max result set size
        private static string[] Attributes = new string[] { "thumbnailphoto", "sAMAccountName" };
        private const string LdapFilter = "(&(objectCategory=person)(objectclass=user)(thumbnailphoto=*)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))";

        public System.DirectoryServices.DirectoryEntry[] GetUsers( NetworkCredential credential )
        {
            var users = new List<System.DirectoryServices.DirectoryEntry>();
            var domain = Domain.GetComputerDomain();
            var entry = domain.GetDirectoryEntry();
            string path = entry.Path;
            var ldap = new LdapDirectoryIdentifier( domain.Name );
            var connection = new LdapConnection( ldap );
            connection.Credential = credential == null ? CredentialCache.DefaultNetworkCredentials : credential;
            var request = new SearchRequest( path, LdapFilter, SearchScope.Subtree, Attributes );
            var control = new DirSyncRequestControl( _cookie, DirectorySynchronizationOptions.IncrementalValues, Int32.MaxValue );
            request.Controls.Add( control );
            connection.Timeout = new TimeSpan( 0, 2, 0 );
            var response = (SearchResponse)connection.SendRequest( request );
            bool loop = true;
            while( loop )
            {
                foreach( System.DirectoryServices.DirectoryEntry e in response.Entries )
                {
                    users.Add( e );
                }
                foreach( DirectoryControl c in response.Controls )
                {
                    if( c is DirSyncResponseControl )
                    {
                        var dsrc = (DirSyncResponseControl)c;
                        _cookie = dsrc.Cookie;
                        loop = dsrc.MoreData;
                    }
                }
                control.Cookie = _cookie;
                response = (SearchResponse)connection.SendRequest( request );
            }
            return users.ToArray();
        }
    }
}