#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os
from collections import OrderedDict

import remora.common.merge_dicts as merge_dicts
import remora.tests.unit.base as base


class TestMergeDicts(base.TestCase):

    def test_merge_dicts(self):
        #dirname = os.path.dirname(__file__)
        #fixtures_dir = os.path.join(dirname, '..', 'fixtures', 'common')

        #self.assertNotEqual(utils.tar_gz_base64(fixtures_dir), '')
        expected_return = {'kubernetes': {'some-key1': ['some-key1-1-default'], 'some-key2': 'some-key2-default', 'image': {'pullPolicy': 'Always', 'tag': 'v1.8.2', 'repository': 'gcr.io/google_containers/hyperkube-arm64'}, 'labels': ['node-role.kubernetes.io/master-default', 'node-role.kubernetes.io/master', 'node-role.kubernetes.io/master-arm64', {'sub-label2': ['sub2-1-default', {'subsub-label12': ['subsub2-1-default']}], 'sub-label1': ['sub1-1-default', 'sub1-2-default', {'subsub-label1': ['subsub1-2-default', 'subsub1-1-arm64', 'subsub1-1-default']}]}, {'sub-label2': ['sub2-1-default', {'subsub-label12': ['subsub2-1-default']}], 'sub-label1': ['sub1-1-default', 'sub1-2-default', 'sub1-1-arm64', {'subsub-label1': ['subsub1-1-default', 'subsub1-2-default']}]}]}}
        dict1 = {'kubernetes': {'image': {'repository': 'gcr.io/google_containers/hyperkube-arm64'}, 'labels': ['node-role.kubernetes.io/master-arm64', 'node-role.kubernetes.io/master', {'sub-label1': [{'subsub-label1': ['subsub1-1-arm64']}]}, {'sub-label1': ['sub1-1-arm64']}]}}
        dict2 = {'kubernetes': {'some-key1': ['some-key1-1-default'], 'some-key2': 'some-key2-default', 'image': {'pullPolicy': 'Always', 'tag': 'v1.8.2', 'repository': 'gcr.io/google_containers/hyperkube-default'}, 'labels': ['node-role.kubernetes.io/master-default', 'node-role.kubernetes.io/master', {'sub-label1': ['sub1-1-default', 'sub1-2-default', {'subsub-label1': ['subsub1-1-default', 'subsub1-2-default']}]}, {'sub-label2': ['sub2-1-default', {'subsub-label12': ['subsub2-1-default']}]}]}}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)

        expected_return = self.sortOD(expected_return)
        actual_return = self.sortOD(actual_return)

        self.assertEqual(expected_return, actual_return)


    def sortOD(self, od):
        res = OrderedDict()
        for k, v in sorted(od.items(), key=lambda x: hash(x)):
            if isinstance(v, dict):
                res[k] = self.sortOD(v)
            else:
                res[k] = v
        return res


#class TestUtilsDecodeEnvDict(base.TestCase):
#
#    def test_decode_env_dict_sigle_dict(self):
#        prefix = 'kube'
#        env = {
#            "version": "v1.6.4"
#        }
#        expected_return = ["export KUBE_VERSION=\"v1.6.4\""]
#
#        self.assertEqual(
#            utils.decode_env_dict(prefix, env), expected_return
#        )
#
#    def test_decode_env_dict_with_list(self):
#        prefix = 'kube'
#        env = {
#            "ips": ['192.168.1.11', '192.168.1.12']
#        }
#        expected_return = ["export KUBE_IPS=\"192.168.1.11 192.168.1.12\""]
#
#        self.assertEqual(
#            utils.decode_env_dict(prefix, env), expected_return
#        )
#
#    def test_decode_env_dict_multiple_value(self):
#        prefix = 'kube'
#        env = {
#            "version": "v1.6.4",
#            "ips": ['192.168.1.11', '192.168.1.12']
#        }
#
#        self.assertEqual(len(utils.decode_env_dict(prefix, env)), 2)
