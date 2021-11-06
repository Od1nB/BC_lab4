import * as React from 'react';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';


// interface Props {
//     accs : string
// }

interface Props {
    accounts : string[]
}
const AccountsTable : React.FC<Props> = (props) => {
    return (
        <TableContainer component={Paper}>
          <Table sx={{ minWidth: 650 }} size="small" aria-label="a dense table">
            <TableHead>
              <TableRow>
                <TableCell>Accounts</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {props.accounts.map((account, i) => (
                <TableRow
                  key={account + String(i)}
                >
                  <TableCell component="th" scope="row">
                    {account}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      );
}
export default AccountsTable;
