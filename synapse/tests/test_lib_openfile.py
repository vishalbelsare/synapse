from synapse.tests.common import *

import synapse.lib.webapp as s_webapp
import synapse.lib.openfile as s_openfile

class OpenFileTest(SynTest):

    def test_openfile_abs(self):

        with self.getTestDir() as dirname:

            with genfile(dirname, 'foo.bin') as fd:
                fd.write(b'asdfqwer')

            path = genpath(dirname, 'foo.bin')
            with s_openfile.openfd(path) as fd:
                self.eq(fd.read(), b'asdfqwer')

    def test_openfile_relative(self):

        with self.getTestDir() as dirname:

            with genfile(dirname, 'foo.bin') as fd:
                fd.write(b'asdfqwer')

            opts = {'file:basedir': dirname}
            with s_openfile.openfd('foo.bin', **opts) as fd:
                self.eq(fd.read(), b'asdfqwer')

    def test_openfile_http(self):
        self.thisHostMustNot(platform='windows')
        fdir = getTestPath()

        wapp = s_webapp.WebApp()
        wapp.listen(0, host='127.0.0.1')
        wapp.addFilePath('/v1/test/(.*)', fdir)
        port = wapp.getServBinds()[0][1]

        with s_openfile.openfd('http://127.0.0.1:{}/v1/test/test.dat'.format(port)) as fd:
            self.true(fd.read().find(b'woot') != -1)
